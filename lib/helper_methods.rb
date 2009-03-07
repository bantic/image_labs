class Magick::Pixel
  # create a gray pixel
  def self.gray(val)
    self.new(val,val,val)
  end
end

# load an image
def img(img_path)
  Magick::ImageList.new(img_path)
end

# a gray pixel
def gray(val)
  Magick::Pixel.gray(val)
end