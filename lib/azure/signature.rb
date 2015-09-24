require 'uri'

# The Azure module serves as a namespace.
module Azure
  # The Signature class encapsulates an canonicalized resource string.
  class Signature
    attr_reader :resource
    attr_reader :canonical_url

    # Creates and returns an Azure::Signature object taking a +resource+ as an
    # argument. The +resource+ will typically be an Azure storage account endpoint.
    #
    def initialize(resource, key)
      @resource = resource
      @canonical_url = canonicalize_url(resource)
    end

    # Generate a signature for use with the table service based using
    # +auth_type+ which may either be SharedKey (the default) or
    # SharedKeyLight.
    #
    # If using SharedKey you may also specify the verb which is GET by default.
    #
    # For any auth type you may also specify the date used as part of the
    # signature generation. The default is Time.now.utc.
    #
    def table_signature(auth_type = 'SharedKey', verb = 'GET', date = Time.now.utc)
      unless ['SharedKey', 'SharedKeyLight'].include?(auth_type)
        raise ArgumentError, "auth type must be SharedKey or SharedKeyLight"
      end

      if auth_type == 'SharedKey'
        data = "#{verb}\n\n#{date}\n#{resource}"
      else
        data = "#{date}\n#{resource}"
      end

      generate_digest(data)
    end

    private

    # Generate a canonical URL from an endpoint.
    def canonicalize_url(url)
      uri = URI.parse(url)
      curl = "/" << uri.host.split(".").first
      curl << uri.path.to_s << "\n" 

      if uri.query
        hash = Hash.new{ |hash, key| hash[key] = [] }
        array = uri.query.tr('=',':').split("&")

        curl << array.each_with_object(hash){ |e,h|
          k,v = e.split(':')
          h[k] << v
        }.map{ |k,v| k + ':' + v.sort * ',' }.sort * "\n"
      end

      curl
    end

    # Generate a digest based on the +data+ argument, using the key
    # passed to constructor.
    #
    def generate_digest(data)
      sha = OpenSSL::Digest::SHA256.new
      Base64.strict_encode64(OpenSSL::HMAC.digest(sha, key, data))
    end
  end
end

if $0 == __FILE__
  include Azure
  s = Signature.new(url, 'xyz')
  p s.canonical_url
  #p s.canonicalize_url(url)
end
