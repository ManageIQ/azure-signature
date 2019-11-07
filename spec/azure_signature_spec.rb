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
      expect(@sig.account_name).to eql('testsnapshots')
    end

    example 'resource method basic functionality' do
      expect(@sig).to respond_to(:resource)
      expect(@sig.resource).to eql(@url)
    end

    example 'uri method basic functionality' do
      expect(@sig).to respond_to(:uri)
      expect(@sig.uri).to be_kind_of(Addressable::URI)
    end

    example 'url is an alias for the resource method' do
      expect(@sig).to respond_to(:url)
      expect(@sig.method(:url)).to eql(@sig.method(:resource))
    end
  end

  context 'canonical resource' do
    example 'canonical_resource method basic functionality' do
      expect(@sig).to respond_to(:canonical_resource)
      expect(@sig.canonical_resource).to be_kind_of(String)
    end

=begin
    test "canonical_url is an alias for the canonical_resource method" do
      assert_respond_to(@sig, :canonical_url)
      assert_alias_method(@sig, :canonical_url, :canonical_resource)
    end

    test "canonical_resource returns the expected value for basic url" do
      @url = "http://myaccount.blob.core.windows.net/Tables"
      @sig = Azure::Signature.new(@url, @key)
      expected = "/myaccount/Tables"
      assert_equal(expected, @sig.canonical_resource)
    end

    test "canonical_resource returns the expected value for url with query" do
      @url = "http://myaccount.blob.core.windows.net/mycontainer?restype=container&comp=metadata"
      @sig = Azure::Signature.new(@url, @key)
      expected = "/myaccount/mycontainer\ncomp:metadata\nrestype:container"
      assert_equal(expected, @sig.canonical_resource)
    end

    test "canonical_resource returns the expected value for url with multiple, identical query params" do
      @url = "http://myaccount.blob.core.windows.net/mycontainer?restype=container"
      @url << "&comp=list&include=snapshots&include=metadata&include=uncommittedblobs"
      @sig = Azure::Signature.new(@url, @key)
      expected = "/myaccount/mycontainer\ncomp:list\ninclude:metadata,snapshots,"
      expected << "uncommittedblobs\nrestype:container"
      assert_equal(expected, @sig.canonical_resource)
    end

    test "canonical_resource returns the expected value for secondary account" do
      @url = "https://myaccount-secondary.blob.core.windows.net/mycontainer/myblob"
      @sig = Azure::Signature.new(@url, @key)
      expected = "/myaccount/mycontainer/myblob"
      assert_equal(expected, @sig.canonical_resource)
    end
=end
  end

=begin
  test "constructor automatically escapes resource argument" do
    @url = "https://myaccount-secondary.blob.core.windows.net/mycontainer/myblob-{12345}"
    @sig = Azure::Signature.new(@url, @key)
    assert_equal("/myaccount/mycontainer/myblob-%7B12345%7D", @sig.canonical_resource)
    assert_equal("https://myaccount-secondary.blob.core.windows.net/mycontainer/myblob-%7B12345%7D", @sig.resource)
  end

  test "constructor requires two arguments" do
    assert_raise(ArgumentError){ Azure::Signature.new }
    assert_raise(ArgumentError){ Azure::Signature.new('http://foo/bar') }
  end

  test "table_signature basic functionality" do
    assert_respond_to(@sig, :table_signature)
  end

  test "blob_signature basic functionality" do
    assert_respond_to(@sig, :blob_signature)
  end

  test "file_signature and queue_signature are aliases for blob_signature" do
    assert_alias_method(@sig, :blob_signature, :file_signature)
    assert_alias_method(@sig, :blob_signature, :queue_signature)
  end

  def teardown
    @key = nil
    @url = nil
    @sig = nil
  end
=end
end
