class EdgeDetector
  X_MASK = [[-1, 0, 1],
            [-1, 0, 1],
            [-1, 0, 1]]

  Y_MASK = [[ 1,  1,  1],
            [ 0,  0,  0],
            [-1, -1, -1]]

  # get the value of the x-mask at i,j
  def x_mask(x_value, y_value)
    X_MASK[y_value + 1][x_value + 1]
  end

  # get the value of the y-mask at i,j
  def y_mask(x_value, y_value)
    Y_MASK[y_value + 1][x_value + 1]
  end
  
  # we assume the image is grayscale
  def initialize(image_path)
    @gray = img(image_path)
  end
  
  def detect_edges!(output_path="prewitt_ruby_out.jpg")
    @gray_view        = @gray.view(0,0,@gray.columns,@gray.rows)
    @gray_out_view    = @gray.view(0,0,@gray.columns,@gray.rows)

    right = @gray.columns - 1
    bottom = @gray.rows - 1

    0.upto( right ) do |x|
      0.upto( bottom ) do |y|

        magnitude = xsum = ysum = 0

        if x == 0 || y == 0 || x == right || y == bottom
          magnitude = 0
        else
          # for the 8 surrounding pixels to x,y, apply the filter value and add to the xsum
          [-1,0,1].each do |i|
            [-1,0,1].each do |j|
              # can use .red since all pixel values are the same since we are grayscale
              # note that we have to invert j and i in the x_mask and y_mask calls
              xsum += @gray_view[y + j][x + i].red * x_mask(i,j)
              ysum += @gray_view[y + j][x + i].red * y_mask(i,j)
            end
          end
        end

        magnitude = xsum.abs + ysum.abs
        magnitude = [magnitude, 255].min # cap at 255

        @gray_out_view[y][x] = Magick::Pixel.gray(magnitude)
      end
    end
    
    @gray_out_view.sync
    @gray.write(output_path)
  end
  
end

