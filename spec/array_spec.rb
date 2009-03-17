require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'

describe Array do
  describe "#two_d_array" do
    it "should work" do
      cols = 30
      rows = 10
      
      arr = Array.two_d_array(cols,rows)

      arr[0].size.should == 10
      arr.size.should == 30
    end
  end
end