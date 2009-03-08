require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'
require 'fileutils'

describe EdgeDetector do
  before(:all) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end
  
  it "should create the correct output" do
    ed = EdgeDetector.new(@fixtures_path + "/cart_gray.jpg")
    ed.detect_edges!(@tmp_path + "/output.jpg")
    
    (@tmp_path + "/output.jpg").should equal_image(@fixtures_path + "/cart_edges.jpg")
  end
  
  it "should only accept grayscale images for edge detection" do
    lambda { EdgeDetector.new(@fixtures_path + "/color.jpg") }.should raise_error
  end
  
  after(:all) do
    `rm -rf #{@tmp_path}`
  end
end