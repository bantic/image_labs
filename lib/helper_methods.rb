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
  # Do something to all the pixels specified in +locations_array+
  # Locations_array is an array of [column,row] tuples
  def manipulate_pixels(locations_array, &blck)
    pixels = get_pixels(0,0,columns,rows)
    locations_array.each do |column, row|
      pixels[ row * columns + column ] = yield pixels[ row * columns + column ]
    end
    store_pixels(0,0,columns,rows,pixels)
  end
  
  def manipulate_pixels_with_get_pixels(locations_array, &blck)
    pixels = get_pixels(0,0,columns,rows)
    locations_array.each do |column, row|
      pixels[ row * columns + column ] = yield pixels[ row * columns + column ]
    end
    store_pixels(0,0,columns,rows,pixels)
  end
  
  # def manipulate_pixels_with_export_pixels(locations_array, &blck)
  #   pixels = import_pixels(0,0,columns,rows,"RGB")
  #   locations_array.each do |column, row|
  #     new_pixel = yield pixels[]
  #     pixels[ 3 * (row*columns + column), 3 ] 
  #   end
  # end
  
  def x_range
    (0..(columns - 1))
  end
  
  def y_range
    (0..(rows - 1))
  end
  
  def bottom
    rows - 1
  end
  
  def right
    columns - 1
  end
  
  # Returns a two-d array of pixel grayscale values
  def two_d_array
    Kernel.raise ArgumentError, "Only call two_d_array on a grayscale image" unless gray?
    two_d_array_with_export_pixels
  end
  
  # Returns the actual two-d array of pixels themselves
  def two_d_array_of_pixels
    _pixels = get_pixels(0,0,columns,rows)
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |x|
      0.upto(rows - 1) do |y|
        array[y][x] = _pixels[y*columns + x]
      end
    end
    
    array
  end
  
  def two_d_array_with_export_pixels
    _pixels = export_pixels(0, 0, columns, rows, "I")
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |x|
      0.upto(rows - 1) do |y|
        array[y][x] = _pixels[y*columns + x]
      end
    end
    
    array
  end
  
  def two_d_array_with_dispatch
    _pixels = dispatch(0,0,columns,rows,"I")
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