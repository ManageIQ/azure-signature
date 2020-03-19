require 'rspec'
require 'azure/signature'

RSpec.describe Azure::Signature do
  before do
    @key = 'SGVsbG8gV29ybGQ='
    @url = 'http://testsnapshots.blob.core.windows.net/?comp=list'
    @sig = described_class.new(@url, @key)
  end

  context 'version constant' do
    example 'version constant is set to expected value' do
      expect(Azure::Signature::VERSION).to eql('0.3.0')
    end

    example "version constant is frozen" do
      expect(Azure::Signature::VERSION).to be_frozen
    end
  end

  context 'instance methods' do
    example 'key method basic functionality' do
      expect(@sig).to respond_to(:key)
      expect(@sig.key).to be_kind_of(String)
    end

    example 'account_name basic functionality' do
      expect(@sig).to respond_to(:account_name)
      expect(@sig.account_name).to eq('testsnapshots')
    end

    example 'resource method basic functionality' do
      expect(@sig).to respond_to(:resource)
      expect(@sig.resource).to eq(@url)
    end

    example 'uri method basic functionality' do
      expect(@sig).to respond_to(:uri)
      expect(@sig.uri).to be_kind_of(Addressable::URI)
    end

    example 'url is an alias for the resource method' do
      expect(@sig).to respond_to(:url)
      expect(@sig.method(:url)).to eq(@sig.method(:resource))
    end
  end

  context 'canonical resource' do
    example 'canonical_resource method basic functionality' do
      expect(@sig).to respond_to(:canonical_resource)
      expect(@sig.canonical_resource).to be_kind_of(String)
    end

    example "canonical_url is an alias for the canonical_resource method" do
      expect(@sig).to respond_to(:canonical_url)
      expect(@sig.method(:canonical_url)).to eq(@sig.method(:canonical_resource))
    end

    example "canonical_resource returns the expected value for basic url" do
      url = "http://myaccount.blob.core.windows.net/Tables"
      sig = Azure::Signature.new(url, @key)
      expect(sig.canonical_resource).to eq("/myaccount/Tables")
    end

    example "canonical_resource returns the expected value for url with query" do
      url = "http://myaccount.blob.core.windows.net/mycontainer?restype=container&comp=metadata"
      sig = Azure::Signature.new(url, @key)
      expect(sig.canonical_resource).to eq("/myaccount/mycontainer\ncomp:metadata\nrestype:container")
    end

    example "canonical_resource returns the expected value for url with multiple, identical query params" do
      url = "http://myaccount.blob.core.windows.net/mycontainer?restype=container"
      url << "&comp=list&include=snapshots&include=metadata&include=uncommittedblobs"
      sig = Azure::Signature.new(url, @key)
      expected = "/myaccount/mycontainer\ncomp:list\ninclude:metadata,snapshots,uncommittedblobs\nrestype:container"
      expect(sig.canonical_resource).to eq(expected)
    end

    example "canonical_resource returns the expected value for secondary account" do
      url = "https://myaccount-secondary.blob.core.windows.net/mycontainer/myblob"
      sig = Azure::Signature.new(url, @key)
      expect(sig.canonical_resource).to eq("/myaccount/mycontainer/myblob")
    end
  end

  context "constructor" do
    example "constructor automatically escapes resource argument" do
      url = "https://myaccount-secondary.blob.core.windows.net/mycontainer/myblob-{12345}"
      sig = Azure::Signature.new(url, @key)
      expect(sig.canonical_resource).to eq("/myaccount/mycontainer/myblob-%7B12345%7D")
      expect(sig.resource).to eq("https://myaccount-secondary.blob.core.windows.net/mycontainer/myblob-%7B12345%7D")
    end

    example "constructor requires two arguments" do
      expect{ Azure::Signature.new }.to raise_error(ArgumentError)
      expect{ Azure::Signature.new('http://foo/bar') }.to raise_error(ArgumentError)
    end

    example "table_signature basic functionality" do
      expect(@sig).to respond_to(:table_signature)
    end

    example "blob_signature basic functionality" do
      expect(@sig).to respond_to(:blob_signature)
    end

    example "file_signature and queue_signature are aliases for blob_signature" do
      expect(@sig.method(:blob_signature)).to eq(@sig.method(:file_signature))
      expect(@sig.method(:blob_signature)).to eq(@sig.method(:queue_signature))
    end
  end
end
