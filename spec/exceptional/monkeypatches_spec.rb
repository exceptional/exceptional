require File.dirname(__FILE__) + '/../spec_helper'
require File.join(File.dirname(__FILE__), '../..', 'lib', 'exceptional', 'monkeypatches')

describe Regexp do
  it "should output a correctly formatted string" do
    /hello/.to_json.should == "\"(?-mix:hello)\""
  end
end
