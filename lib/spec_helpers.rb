require File.dirname(__FILE__) + "/lib"

# Matcher to test equality between images
class EqualImage
  def initialize(other_image)
    @other_image = load_image(other_image)
  end
  
  def load_image(image)
    case image
    when String
      img(image)
    when Magick::ImageList
      image
    when Magick::Image
      il = ImageList.new
      il << image
      il
    end
  end
  
  def matches?(image)
    @image = load_image(image)
    return false unless @image.columns == @other_image.columns &&
                        @image.rows    == @other_image.rows
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

#
# 
#
class NearlyEqualImage
  def initialize(other_image)
    @other_image = load_image(other_image)
    @tolerance = 0.001
  end
  
  def load_image(image)
    case image
    when String
      img(image)
    when Magick::ImageList
      image
    when Magick::Image
      il = ImageList.new
      il << image
      il
    end
  end
  
  def matches?(image)
    @image = load_image(image)
    return false unless @other_image.columns == @image.columns && @other_image.rows == @image.rows
    
    return (@other_image.difference(@image)[1]) < @tolerance
  end
  
  def within(tolerance)
    @tolerance = tolerance
    self
  end
  
  def failure_message
    "expected the images to be equal with tolerance of #{@tolerance}"
  end
  
  def negative_failure_message
    "images should not have been equal (with tolerance #{@tolerance} but they were"
  end
end

def nearly_equal_image(other_image)
  NearlyEqualImage.new(other_image)
end
  