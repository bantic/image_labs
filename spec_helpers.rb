class EqualImage
  def initialize(other_image)
    @other_image = other_image
  end
  
  def matches?(image)
    @image = image
    return (@other_image <=> @image) == 0
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

class Image
  def self.black_image
    Magick::ImageList.new("images/black400x400.jpg")
  end
  def self.white_image
    Magick::ImageList.new("images/white400x400.jpg")
  end
end

require 'spec'
describe Image do
  it "should do equals" do
    img1 = Image.black_image
    img2 = Image.black_image
    
    img1.should equal_image(img2)
  end
  
  it "should do equals" do
    img1 = Image.black_image
    img2 = Image.white_image
    
    img1.should_not equal_image(img2)
  end
  
end

