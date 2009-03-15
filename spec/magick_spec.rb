require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'

describe Magick::Image do
  before(:all) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
  end
  
  
  describe "#manipulate_pixels" do
    it "should change the specified pixels" do
      white = img(@fixtures_path + "/white3x3.png")
      
      red_pixel = Pixel.new(255,0,0)
      white_pixel = Pixel.new(255,255,255)
      
      # change first row only
      white.manipulate_pixels([[0,0],[1,0],[2,0]]) do |pixel|
        red_pixel
      end
      
      white.all_pixels.should == [red_pixel, red_pixel, red_pixel,
                                           white_pixel, white_pixel, white_pixel,
                                           white_pixel, white_pixel, white_pixel]
      
      # now change first column
      white.manipulate_pixels([[0,0],[0,1],[0,2]]) do |pixel|
        red_pixel
      end
      
      white.all_pixels.should == [red_pixel, red_pixel, red_pixel,
                                           red_pixel, white_pixel, white_pixel,
                                           red_pixel, white_pixel, white_pixel]
    end
  end
  
  describe "#two_d_array" do
    it "should return a 2-d array of grayscale values from the image" do
      white = img(@fixtures_path + "/white3x3.png")
      
      white.two_d_array.should == [[255,255,255],[255,255,255],[255,255,255]]
    end
    
    it "should only be called on a grayscale image" do
      color = img(@fixtures_path + "/color.jpg")
      lambda {
        color.two_d_array
      }.should raise_error(ArgumentError)
    end
  end
end