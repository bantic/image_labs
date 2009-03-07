class EqualImage
  def initialize(other_image)
    @other_image = other_image
  end
  
  def matches?(image)
    @image = image
    return false unless @image.rows == @other_image.rows && 
                        @image.columns == @other_image.columns
                        
    @image.get_pixels(0,0,@image.columns,@image.rows) ==
      @other_image.get_pixels(0,0,@other_image.columns, @other_image.rows)
  end
  
  def failure_message
    "expected the images to be equal"
  end
  
  def negative_failure_message
    "images should not have been equal but they were"
  end
end

def equal_image(other_image)
  EqualImage.new(other_image)
end

require 'rubygems'
require 'RMagick'

class BlackImage
  def self.image
    Magick::ImageList.new("images/black400x400.jpg")
  end
  def self.other_image
    Magick::ImageList.new("images/gray.jpg")
  end
end

require 'spec'
describe BlackImage do
  it "should do equals" do
    img1 = BlackImage.image
    img2 = BlackImage.image
    
    img1.should equal_image(img2)
  end
  
  it "should do equals" do
    img1 = BlackImage.image
    img2 = BlackImage.other_image
    
    img1.should_not equal_image(img2)
  end
  
end

