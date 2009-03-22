require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'
require 'fileutils'

describe EdgeDetector do
  before(:each) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end
  
  it "should create the correct output" do
    ed = EdgeDetector.new(@fixtures_path + "/cart_gray.jpg")
    edges = ed.detect_edges
    
    edges.should nearly_equal_image(@fixtures_path + "/cart_edges.jpg")
  end
  
  it "should only accept grayscale images for edge detection" do
    lambda { EdgeDetector.new(@fixtures_path + "/color.jpg") }.should raise_error
  end
  
  after(:each) do
    `rm -rf #{@tmp_path}`
  end
end