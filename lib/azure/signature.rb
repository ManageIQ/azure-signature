require 'uri'

# The Azure module serves as a namespace.
module Azure
  # The Signature class encapsulates an canonicalized resource string.
  class Signature
    attr_reader :resource
    attr_reader :canonical_url
    attr_reader :signature
    attr_reader :digest_type

    # Creates and returns an Azure::Signature object taking a +resource+ as an
    # argument. The +resource+ will typically be an Azure storage account endpoint.
    #
    # You may optionally pass a +digest_type+ as well. The default is sha256.
    #
    def initialize(resource, digest_type = 'sha256')
      @resource = resource
      @canonical_url = canonicalize_url(resource)
      #@signature = generate_signature(@canonical_url)
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

    def generate_digest
      CGI.escape(
        Base64.strict_encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest.new(digest_type), access_key, resource
          )
        )
      ).gsub('+', '%20')
    end
  end
end

if $0 == __FILE__
  include Azure
   # /myaccount/mycontainer\ncomp:list\ninclude:metadata,snapshots,uncommittedblobs\nrestype:container
  url = "http://myaccount.blob.core.windows.net/container?restype=container&comp=list&include=snapshots&include=metadata&include=uncommittedblobs"
  s = Signature.new(url)
  p s.canonical_url
  #p s.canonicalize_url(url)
end
