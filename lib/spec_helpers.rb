require File.dirname(__FILE__) + "/lib"

# Matcher to test equality between images
class EqualImage
  def initialize(other_image)
    @other_image = load_image(other_image)
  end
  
  def load_image(image)
    case image
    when String
      Magick::ImageList.new(image).first
    when Magick::ImageList
      image.first
    when Magick::Image
      image
    end
  end
  
  def matches?(image)
    @image = load_image(image)
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
