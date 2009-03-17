# Add the #two_d_array extension to Array class for convenience
class Array
  def self.two_d_array(columns, rows)
    self.new(columns) {self.new(rows)}
  end
end

class Magick::Pixel
  # create a gray pixel
  def self.gray(val)
    self.new(val,val,val)
  end
end

# Convenience methods useful from the bin/rmagicksh shell
# load an image
def img(img_path)
  Magick::ImageList.new(img_path)
end

# a gray pixel
def gray(val)
  Magick::Pixel.gray(val)
end

class Magick::Image
  # convenience methods
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
  
  # the intensity of this image
  def intensity
    total_intensity = export_pixels(0,0,columns,rows,"I").inject(0) {|sum,intensity| sum += intensity}
    total_intensity / (columns * rows)
  end
  ############
  
  # Do something to all the pixels specified in +locations_array+
  # Locations_array is an array of [column,row] tuples
  # This method yields a Pixel obj for each location in +locations_array+
  def manipulate_pixels(locations_array, &blck)
    manipulate_pixels_with_get_pixels(locations_array, &blck)
  end
  
  # yields a Pixel
  def manipulate_pixels_with_get_pixels(locations_array, &blck)
    pixels = get_pixels(0,0,columns,rows)
    locations_array.each do |column, row|
      pixels[ row * columns + column ] = yield pixels[ row * columns + column ]
    end
    store_pixels(0,0,columns,rows,pixels)
  end

  #########################################################################
  ## The following manipulate_pixels_with_XXX methods are here for
  ## benchmarking purposes. Benchmarking (see benchmark/benchmark.rb)
  ## shows that manipulate_pixels_with_get_pixels is the fastest, so that's
  ## what we use
  #########################################################################

  # yields an array of 3 values for R,G,B 0-255
  def manipulate_pixels_with_export_pixels(locations_array, &blck)
    _pixels = export_pixels(0,0,columns,rows,"RGB")
    locations_array.each do |column, row|
      _pixels[ 3 * (row*columns + column), 3] = yield _pixels[ 3 * (row*columns + column), 3]
    end
    import_pixels(0,0,columns,rows,"RGB",_pixels)
  end

  # yields an array of 3 values for R,G,B 0-255
  def manipulate_pixels_with_export_pixels_as_str(locations_array, &blck)
    _pixels = export_pixels_to_str(0,0,columns,rows,"RGB").unpack("C*")
    locations_array.each do |column, row|
      _pixels[ 3 * (row*columns + column), 3] = yield _pixels[ 3 * (row*columns + column), 3]
    end
    t = Time.now
    import_pixels(0,0,columns,rows,"RGB",_pixels)
  end
  
  # yields a pixel
  def manipulate_pixels_with_view(locations_array, &blck)
    _view = view(0,0,columns,rows)
    locations_array.each do |column, row|
      _view[row][column] = yield _view[row][column]
    end
    _view.sync
  end
  ########################################################################
  ######## / alternative manipulate_pixels_with_XXX methods ##############
  ########################################################################
  
  # Returns a two-d array of pixel grayscale values 0-255
  def two_d_array
    Kernel.raise ArgumentError, "Only call two_d_array on a grayscale image" unless gray?
    two_d_array_with_export_pixels
  end
  
  def all_pixels(as_pixels=true)
    if as_pixels
      get_pixels(0,0,columns,rows)
    else # as arrays of 0-255 ints
      single_array = export_pixels(0,0,columns,rows,"RGB")
      array_of_pixel_arrays = []
      single_array.each_slice(3) { |slice| array_of_pixel_arrays << slice }
      array_of_pixel_arrays
    end
  end
  
  def all_pixels_as_arrays
    all_pixels(false)
  end
  
  # returns an array of [r,g,b] arrays
  def export_pixels_as_arrays(x,y,w,h)
    single_array = export_pixels(x,y,w,h,"RGB")
    array_of_pixel_arrays = []
    single_array.each_slice(3) { |slice| array_of_pixel_arrays << slice }
    array_of_pixel_arrays
  end

  def two_d_array_with_export_pixels
    _pixels = export_pixels(0, 0, columns, rows, "I")
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |column|
      0.upto(rows - 1) do |row|
        array[column][row] = _pixels[row*columns + column]
      end
    end
    
    array
  end
  
  # Returns the actual two-d array of pixels themselves
  def two_d_array_of_pixels
    _pixels = get_pixels(0,0,columns,rows)
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |column|
      0.upto(rows - 1) do |row|
        array[column][row] = _pixels[row*columns + column]
      end
    end
    
    array
  end

  ############# Benchmarking alternatives two_d_array #####################
  def two_d_array_with_dispatch
    _pixels = dispatch(0,0,columns,rows,"I")
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |column|
      0.upto(rows - 1) do |row|
        array[column][row] = _pixels[row*columns + column]
      end
    end
    
    array
  end
  
  def two_d_array_with_view
    _view = view(0,0,columns,rows)
    array = Array.two_d_array(columns, rows)
    0.upto(columns - 1) do |column|
      0.upto(rows - 1) do |row|
        array[column][row] = _view[row][column].red
      end
    end
    
    array
  end
  ############# /Benchmarking alternatives #################################
end
