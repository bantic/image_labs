require File.dirname(__FILE__) + "/../../lib/spec_helpers"
require 'spec'

describe Blender do
  before do
    @white_3x3 = Image.new(3,3) {self.background_color = 'white'}
    @black_3x3 = Image.new(3,3) {self.background_color = 'black'}
    @red_3x3   = Image.new(3,3) {self.background_color = 'red'}
    @white_pixel = Pixel.new(255,255,255)
    @black_pixel = Pixel.new(0,0,0)
  end
  
  describe "basic" do
    it "should raise an error if the images are different sizes" do
      img_4x4 = Image.new(4,4)
      lambda {
        Blender.add(@white_3x3,img_4x4)
      }.should raise_error(ArgumentError)
    end
  end
  
  describe "#add" do
    it "should work correctly" do
      blended = Blender.add(@white_3x3, @black_3x3)
      blended.all_pixels.should == [@white_pixel] * 9
    end
    
    it "should cap at max (255)" do
      blended = Blender.add(@white_3x3, @white_3x3)
      blended.all_pixels.should == [@white_pixel] * 9
    end
  end
  
  describe "#multiply" do
    it "should work correctly on black-and-white images" do
      blended = Blender.multiply(@white_3x3, @black_3x3)
      blended.all_pixels.should == [@black_pixel] * 9
    end
    
    it "should work correctly on a gray image" do
      gray_image = Image.new(3,3) {self.background_color = 'rgb(75,75,75)' }
      blended = Blender.multiply(gray_image, gray_image)
      # multiplied_value = 75 * 75 / 255 = 22
      blended.all_pixels.should == [gray(22)] * 9
    end
  end
  
  describe "#difference" do
    it "should work correctly" do
      image1_pixels = [@white_pixel, @white_pixel, @white_pixel,
                       @white_pixel, @black_pixel, @white_pixel,
                       @white_pixel, @white_pixel, @white_pixel]
      image1 = Image.new(3,3)
      image1.store_pixels(0,0,3,3,image1_pixels)
      blended = Blender.difference(image1, @white_3x3)
      blended.all_pixels.should == [@black_pixel, @black_pixel, @black_pixel,
                                    @black_pixel, @white_pixel, @black_pixel,
                                    @black_pixel, @black_pixel, @black_pixel]
    end
  end
end
