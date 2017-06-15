require 'test-unit'
require 'azure/signature'

class TC_Azure_Signature < Test::Unit::TestCase
  def setup
    @key = "SGVsbG8gV29ybGQ="
    @url = 'http://testsnapshots.blob.core.windows.net/?comp=list'
    @sig = Azure::Signature.new(@url, @key)
  end

  test "version constant is set to expected value" do
    assert_equal("0.3.0", Azure::Signature::VERSION)
  end

  test "key method basic functionality" do
    assert_respond_to(@sig, :key)
    assert_kind_of(String, @sig.key)
  end

  test "account_name basic functionality" do
    assert_respond_to(@sig, :account_name)
    assert_equal('testsnapshots', @sig.account_name)
  end

  test "resource method basic functionality" do
    assert_respond_to(@sig, :resource)
    assert_equal(@url, @sig.resource)
  end

  test "url is an alias for the resource method" do
    assert_respond_to(@sig, :url)
    assert_alias_method(@sig, :url, :resource)
  end

  test "uri method basic functionality" do
    assert_respond_to(@sig, :uri)
    assert_kind_of(Addressable::URI, @sig.uri)
  end

  test "canonical_resource method basic functionality" do
    assert_respond_to(@sig, :canonical_resource)
    assert_kind_of(String, @sig.canonical_resource)
  end

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
end
