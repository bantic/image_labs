class Magick::Pixel
  # create a gray pixel
  def self.gray(val)
    self.new(val,val,val)
  end
end

class Array
  def self.two_d_array(columns, rows)
    self.new(rows) {self.new(columns)}
  end
end

class Magick::Image
  def two_d_array
    two_d_array_with_export_pixels
  end
  
  def two_d_array_with_export_pixels
    _pixels = export_pixels(0,0,columns,rows,"R")
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |x|
      0.upto(rows - 1) do |y|
        array[y][x] = _pixels[y*columns + x]
      end
    end
    
    array
  end
  
  def two_d_array_with_view
    _view = view(0,0,columns,rows)
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |x|
      0.upto(rows - 1) do |y|
        array[y][x] = _view[y][x].red
      end
    end
    
    array
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