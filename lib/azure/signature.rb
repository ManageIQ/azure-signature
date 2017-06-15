require 'addressable'
require 'openssl'
require 'base64'
require 'time'
require 'active_support/core_ext/hash/conversions'

# The Azure module serves as a namespace.
module Azure
  # The Signature class encapsulates an canonicalized resource string.
  class Signature
    # The version of the azure-signature library.
    VERSION = '0.3.0'.freeze

    # The resource (URL) passed to the constructor.
    attr_reader :resource

    # The canonical version of the resource.
    attr_reader :canonical_resource

    # The base64-decoded account key passed to the constructor.
    attr_reader :key

    # The name of the storage account, based on the resource.
    attr_reader :account_name

    # A URI object that encapsulates the resource.
    attr_reader :uri

    attr_accessor :storage_services_version

    alias url resource
    alias canonical_url canonical_resource

    attr_reader :canonical_headers

    # Creates and returns an Azure::Signature object taking a +resource+ (URL)
    # as an argument and a storage account key. The +resource+ will typically
    # be an Azure storage account endpoint.
    #
    # Note that the +resource+ is automatically escaped.
    #
    def initialize(resource, key)
      @resource = Addressable::URI.escape(resource)
      @uri = Addressable::URI.parse(@resource)
      @account_name = @uri.host.split(".").first.split("-").first
      @key = Base64.strict_decode64(key)
      @canonical_resource = canonicalize_resource(@uri)
      @storage_services_version = '2016-05-31'
    end

    # Generate a signature for use with the table service. Use the +options+
    # hash to pass optional information. The following keys are supported:
    #
    # - :auth_type. Either 'SharedKey' (the default) or 'SharedKeyLight'.
    # - :verb. The http verb used for SharedKey auth. The default is 'GET'.
    # - :date. The date (or x-ms-date) used. The default is Time.now.httpdate.
    # - :content_md5. The Content-MD5 if desired. The default is nil.
    # - :content_type. The Content-Type if desired. The default is nil.
    # - :auth_string. If true, prepends the auth_type + account name to the
    #    result and returns a string. The default is false.
    #
    # You may also use the string forms as keys, e.g. "Auth-Type" instead of
    # :auth_type, if you prefer.
    #
    # The result is a digest string that you can use as an authorization header
    # for future http requests to (presumably) Azure storage endpoints.
    #
    def table_signature(options = {})
      options = options.transform_keys { |key| key.to_s.downcase.tr('_', '-') }

      auth_type    = options['auth-type'] || 'SharedKey'
      verb         = options['verb'] || 'GET'
      date         = options['date'] || options['x-ms-date'] || Time.now.httpdate
      auth_string  = options['auth-string'] || false
      content_md5  = options['content-md5']
      content_type = options['content-type']

      unless ['SharedKey', 'SharedKeyLight'].include?(auth_type)
        raise ArgumentError, "auth type must be SharedKey or SharedKeyLight"
      end

      if auth_type == 'SharedKey'
        body = [verb, content_md5, content_type, date, canonical_resource].join("\n").encode('UTF-8')
      else
        body = [date, canonical_resource].join("\n").encode('UTF-8')
      end

      if auth_string
        "#{auth_type} #{account_name}:" + sign(body)
      else
        sign(body)
      end
    end

    # Generate a signature for use with the blob service. Use the +headers+
    # hash to pass optional information. The following additional keys are
    # supported:
    #
    # - :auth_type. Either 'SharedKey' (the default) or 'SharedKeyLight'.
    # - :verb. The http verb used for SharedKey auth. The default is 'GET'.
    # - :x_ms_date. The x-ms-date used. The default is Time.now.httpdate.
    # - :x_ms_version. The x-ms-version used. The default is '2016-05-31'.
    # - :auth_string. If true, prepends the auth_type + account name to the
    #    result and returns a string. The default is false.
    #
    # You may also use the string forms as keys, e.g. "Auth-Type" instead of
    # :auth_type, if you prefer.
    #
    # The other headers of potential significance are below. Note that you
    # are not required to set any of them.
    #
    # - 'Content-Encoding'
    # - 'Content-Language'
    # - 'Content-Length'
    # - 'Content-MD5'
    # - 'Content-Type'
    # - 'Date'
    # - 'If-Modified-Since'
    # - 'If-Match'
    # - 'If-None-Match'
    # - 'If-Unmodified-Since'
    # - 'Range'
    #
    # The result is a digest string that you can use as an authorization header
    # for future http requests to (presumably) Azure storage endpoints.
    #
    # Example:
    #
    #  require 'azure-signature'
    #  require 'rest-client'
    #
    #  url = "https://yourstuff.blob.core.windows.net/system?restype=container&comp=list&include=snapshots"
    #  key = "xyzabcwhatever"
    #
    #  sig  = Signature.new(url, key)
    #  date = Time.now.httpdate
    #  vers = '2016-05-31'
    #
    #  headers = {
    #    'x-ms-date'    => date,
    #    'x-ms-version' => vers,
    #    'Accept'       => 'application/xml',
    #    :auth_string   => true,
    #  }
    #
    #  sig = sig.blob_signature(headers)
    #  headers['Authorization'] = sig
    #
    #  req = RestClient::Request.new(
    #    :method => 'get',
    #    :url => url,
    #    :headers => headers
    #  )
    #
    #  response = req.execute
    #  p response.body
    #
    def blob_signature(headers = {})
      headers = headers.transform_keys { |key| key.to_s.downcase.tr('_', '-') }

      # These are not actually headers, but internally used options
      auth_string = headers.delete('auth-string') || false
      auth_type   = headers.delete('auth-type') || 'SharedKey'
      verb        = headers.delete('verb') || 'GET'

      unless ['SharedKey', 'SharedKeyLight'].include?(auth_type)
        raise ArgumentError, "auth type must be 'SharedKey' or 'SharedKeyLight'"
      end

      headers['x-ms-date'] ||= headers['date'] || Time.now.httpdate
      headers['x-ms-version'] ||= headers['version'] || storage_services_version

      if auth_type == 'SharedKeyLight'
        headers['date'] ||= headers['x-ms-date'] || Time.now.httpdate
      end

      body = generate_string(verb, headers, auth_type).encode('UTF-8')

      if auth_string
        "SharedKey #{account_name}:" + sign(body)
      else
        sign(body)
      end
    end

    alias file_signature blob_signature
    alias queue_signature blob_signature

    # Generic wrapper method for getting a signature, where +type+ can be
    # :table, :blob, :queue, or :file.
    #
    def signature(type, args = {})
      case type.to_s.downcase
        when 'table'
          table_signature(args)
        when 'blob', 'file', 'queue'
          blob_signature(args)
        else
          raise ArgumentError, "invalid signature type '#{type}'"
      end
    end

    private

    def generate_string(verb, headers, auth_type)
      headers = headers.transform_keys { |key| key.to_s.downcase.tr('_', '-') }
      canonical_headers = canonicalize_headers(headers)

      if auth_type == 'SharedKeyLight'
       [
          verb.to_s.upcase,
          headers['content-md5'],
          headers['content-type'],
          headers['date'],
          canonical_headers,
          canonical_resource
        ].join("\n")
      else
        [
          verb.to_s.upcase,
          headers['content-encoding'],
          headers['content-language'],
          headers['content-length'],
          headers['content-md5'],
          headers['content-type'],
          headers['date'],
          headers['if-modified-since'],
          headers['if-match'],
          headers['if-none-match'],
          headers['if-unmodified-since'],
          headers['range'],
          canonical_headers,
          canonical_resource,
        ].join("\n")
      end
    end

    # Generate a canonical URL from an endpoint.
    #--
    # Borrowed from azure-sdk-for-ruby. I had my own, but this was nicer.
    #
    def canonicalize_resource(uri)
      resource = '/' + account_name + (uri.path.empty? ? '/' : uri.path)

      nested = (uri.query_values(Array) || []).sort
      memo   = Hash.new { |h, k| h[k] = [] }
      hash   = nested.inject(memo){ |h, a| h[a.first] << a.last; h }
      string = hash.inject('') { |s, a| s << "\n#{a.first}:#{a.last.join(',')}"; s }

      resource + string
    end

    # Generate canonical headers.
    #--
    # Borrowed from azure-sdk-for-ruby.
    #
    def canonicalize_headers(headers)
      headers = headers.map { |k,v| [k.to_s.gsub('_', '-').downcase, v] }
      headers.select! { |k,v| k =~ /^x-ms-/i }
      headers.sort_by! { |k,v| k }
      headers.map! { |k,v| '%s:%s' % [k, v] }
      headers.map! { |h| h.gsub(/\s+/, ' ') }.join("\n")
    end

    # Generate a digest based on the +data+ argument, using the key
    # passed to constructor.
    #
    def sign(body)
      signed = OpenSSL::HMAC.digest('sha256', key, body)
      Base64.strict_encode64(signed)
    end
  end
end
