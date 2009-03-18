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
  
  # uses rmagick/imagemagick edge function. Faster but really low-quality results
  def detect_edges_fast
    edges = @img.edge
    return edges
  end
  
  #
  # Use the binary CoreImageTool to do these edges using Apple's CoreImage
  # filters.
  # See: http://www.entropy.ch/software/macosx/coreimagetool/
  # and:
  # http://github.com/bantic/core_image_tool/tree/master
  def detect_edges_with_core_image_tool(output_filename="edges.png")
    tool_path = "/usr/local/bin/CoreImageTool"
    filename = @img.filename
    command = "#{tool_path} load myimg #{filename} filter myimg CIEdges intensity=1.0 store myimg #{output_filename} public.png"
    `#{command}`
    return img(output_filename)
  end
  
  def detect_edges
    pixel_values     = @img.two_d_array
    pixel_out_values = []
    
    @img.y_range.each do |row|
      print '.' if row % 10 == 0
      @img.x_range.each do |column|

        magnitude = xsum = ysum = 0

        if column == 0 || row == 0 || column == @img.right || row == @img.bottom
          magnitude = MAX_MAGNITUDE
        else
          # for the 8 surrounding pixels to x,y, apply the filter value and add to the xsum
          [-1,0,1].each do |i|
            [-1,0,1].each do |j|
              # can use .red since all pixel values are the same since we are grayscale
              # note that we have to invert j and i in the x_mask and y_mask calls
              xsum += pixel_values[column + j][row + i] * x_mask(i,j)
              ysum += pixel_values[column + j][row + i] * y_mask(i,j)
            end
          end
          
          magnitude = xsum.abs + ysum.abs
        end

        magnitude = [magnitude, MAX_MAGNITUDE].min # cap at MAX_MAGNITUDE
        pixel_out_values << magnitude
      end
    end
    
    edges = Image.new(@img.columns,@img.rows)
    edges.import_pixels(0,0,@img.columns,@img.rows,"I",pixel_out_values)
    edges
  end
  
end

