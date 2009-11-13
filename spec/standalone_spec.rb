require File.dirname(__FILE__) + '/spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'exceptional', 'integration', 'rails')

describe Exceptional do
  it "set the api key" do
    Exceptional.configure('api-key')
    Exceptional::Config.api_key.should == 'api-key'
  end
end