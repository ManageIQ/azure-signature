require 'uri'
require 'openssl'
require 'base64'
require 'cgi'
require 'time'

# The Azure module serves as a namespace.
module Azure
  # The Signature class encapsulates an canonicalized resource string.
  class Signature
    # The version of the azure-signature library.
    VERSION = '0.2.0'

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

    alias url resource
    alias canonical_url canonical_resource

    attr_reader :canonical_headers

    # Creates and returns an Azure::Signature object taking a +resource+ (URL)
    # as an argument and a storage account key. The +resource+ will typically
    # be an Azure storage account endpoint.
    #
    def initialize(resource, key)
      @resource = resource
      @uri = URI.parse(resource)
      @account_name = @uri.host.split(".").first.split("-").first
      @key = Base64.strict_decode64(key)
      @canonical_resource = canonicalize_resource(resource)
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
    # The result is a digest string that you can use as an authorization header
    # for future http requests to (presumably) Azure storage endpoints.
    #
    def table_signature(options = {})
      auth_type = options[:auth_type] || 'SharedKey'
      verb = options[:verb] || 'GET'
      date = options[:date] || Time.now.httpdate
      auth_string = options[:auth_string] || false
      content_md5 = options[:content_md5] || options['Content-MD5']
      content_type = options[:content_type] || options['Content-Type']

      unless ['SharedKey', 'SharedKeyLight'].include?(auth_type)
        raise ArgumentError, "auth type must be SharedKey or SharedKeyLight"
      end

      if auth_type == 'SharedKey'
        body = [verb, content_md5, content_type, date, canonical_resource].join("\n").encode('UTF-8')
      else
        body = [date, canonical_resource].join("\n").encode('UTF-8')
      end

      if auth_string
        "Authorization: #{auth_type} #{account_name}:" + sign(body)
      else
        sign(body)
      end
    end

    def blob_signature(headers = {})
      auth_string = headers.delete(:auth_string) || false
      auth_type = headers.delete(:auth_type) || 'SharedKey'
      verb = headers.delete(:verb) || 'GET'

      unless ['SharedKey', 'SharedKeyLight'].include?(auth_type)
        raise ArgumentError, "auth type must be SharedKey or SharedKeyLight"
      end

      headers['x-ms-date'] ||= headers.delete(:x_ms_date) || Time.now.httpdate
      headers['x-ms-version'] ||= headers.delete(:x_ms_version) || '2015-02-21'

      if auth_type == 'SharedKeyLight'
        headers['Date'] ||= headers['x-ms-date'] || headers[:date] || Time.now.httpdate
      end

      body = generate_string(verb, headers, auth_type).encode('UTF-8')

      if auth_string
        "Authorization: SharedKey #{account_name}:" + sign(body)
      else
        sign(body)
      end
    end

    # Generic wrapper method for getting a signature, where +type+ can be
    # :table, :blob, :queue, or :file.
    #
    # At the moment only :table is supported.
    #--
    # TODO: Add support for other types.
    #
    def signature(type, args = {})
      case type.to_s.downcase
        when 'table'
          table_signature(args)
        when 'blob'
          blob_signature(args)
      end
    end

    private

    def generate_string(verb, headers, auth_type)
      canonical_headers = canonicalize_headers(headers)

      if auth_type == 'SharedKeyLight'
       [
          verb.to_s.upcase,
          headers['Content-MD5'],
          headers['Content-Type'],
          headers['Date'],
          canonical_headers,
          canonical_resource
        ].join("\n")
      else
        [
          verb.to_s.upcase,
          headers['Content-Encoding'],
          headers['Content-Language'],
          headers['Content-Length'],
          headers['Content-MD5'],
          headers['Content-Type'],
          headers['Date'],
          headers['If-Modified-Since'],
          headers['If-Match'],
          headers['If-None-Match'],
          headers['If-Unmodified-Since'],
          headers['Range'],
          canonical_headers,
          canonical_resource,
        ].join("\n")
      end
    end

    # Generate a canonical URL from an endpoint.
    #--
    # Borrowed from azure-sdk-for-ruby. I had my own, but this was nicer.
    #
    def canonicalize_resource(url)
      resource = '/' + account_name + (uri.path.empty? ? '/' : uri.path)
      params = CGI.parse(uri.query.to_s).map { |k,v| [k.downcase, v] }
      params.sort_by! { |k,v| k }
      params.map! { |k,v| '%s:%s' % [k, v.map(&:strip).sort.join(',')] }
      [resource, *params].join("\n")
    end

    # Generate canonical headers.
    #--
    # Borrowed from azure-sdk-for-ruby.
    #
    def canonicalize_headers(headers)
      headers = headers.map { |k,v| [k.to_s.gsub('_', '-').downcase, v] }
      headers.select! { |k,v| k =~ /^x-ms-/ }
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
