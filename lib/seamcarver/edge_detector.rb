class EdgeDetector
  
  # Use Prewitt Edge Detection
  X_MASK = [[-1, 0, 1],
            [-1, 0, 1],
            [-1, 0, 1]]

  Y_MASK = [[ 1,  1,  1],
            [ 0,  0,  0],
            [-1, -1, -1]]

  MAX_MAGNITUDE = begin
    QuantumRange
  rescue => e
    MaxRGB
  rescue => e
    255
  end

  def x_mask(x_value, y_value)
    X_MASK[y_value + 1][x_value + 1]
  end

  def y_mask(x_value, y_value)
    Y_MASK[y_value + 1][x_value + 1]
  end
  
  # we assume the image is grayscale
  def initialize(img_path_or_img)
    @img = case img_path_or_img
    when String
      img(img_path_or_img)
    else
      img_path_or_img
    end
    
    raise ArgumentError, "Image should be grayscale" unless @img.gray?
  end
  
  def detect_edges_fast
    edges = @img.edge
    return edges
  end
  
  def detect_edges
    pixel_values     = @img.two_d_array
    pixel_out_values = Array.two_d_array(@img.columns, @img.rows)
    
    @img.x_range.each do |x|
      @img.y_range.each do |y|

        magnitude = xsum = ysum = 0

        if x == 0 || y == 0 || x == @img.right || y == @img.bottom
          magnitude = MAX_MAGNITUDE
        else
          # for the 8 surrounding pixels to x,y, apply the filter value and add to the xsum
          [-1,0,1].each do |i|
            [-1,0,1].each do |j|
              # can use .red since all pixel values are the same since we are grayscale
              # note that we have to invert j and i in the x_mask and y_mask calls
              xsum += pixel_values[y + j][x + i] * x_mask(i,j)
              ysum += pixel_values[y + j][x + i] * y_mask(i,j)
            end
          end
          
          magnitude = xsum.abs + ysum.abs
        end

        magnitude = [magnitude, MAX_MAGNITUDE].min # cap at MAX_MAGNITUDE
        pixel_out_values[y][x] = Magick::Pixel.gray(magnitude)
      end
    end
    
    edges = Image.new(@img.columns,@img.rows)
    edges.store_pixels(0,0,@img.columns,@img.rows,pixel_out_values.flatten)
    edges
  end
  
end

