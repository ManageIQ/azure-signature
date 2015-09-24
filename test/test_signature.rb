require 'test-unit'
require 'azure-signature'

class TC_Azure_Signature < Test::Unit::TestCase
  def setup
    @url = 
    @sig = Azure::Signature.new
  end

  def teardown
    @sig = nil
  end
end
