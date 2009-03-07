require 'rubygems'
require 'RMagick'
require 'helper_methods'

@path = "images/prewitt_in.jpg"  # we assume image is already grayscale
@gray = Magick::ImageList.new(@path)
# @gray = @image.quantize(256, Magick::GRAYColorspace)
# @gray.write("gray.jpg")


@gray_view = @gray.view(0,0,@gray.columns,@gray.rows)
@gray_out_view = @gray.view(0,0,@gray.columns,@gray.rows)

X_MASK = [[-1, 0, 1],
          [-1, 0, 1],
          [-1, 0, 1]]
          
Y_MASK = [[ 1,  1,  1],
          [ 0,  0,  0],
          [-1, -1, -1]]

# get the value of the x-mask at i,j
def x_mask(i,j)
  X_MASK[i + 1][j + 1]
end

# get the value of the y-mask at i,j
def y_mask(i,j)
  Y_MASK[i + 1][j + 1]
end

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
          xsum += @gray_view[y + j][x + i].red * x_mask(j,i)
          ysum += @gray_view[y + j][x + i].red * y_mask(j,i)
        end
      end
    end
    
    magnitude = xsum.abs + ysum.abs
    magnitude = [magnitude, 255].min # cap at 255
    
    val = 255 - magnitude # why do we invert this here? would be easier if we didn't do so later when finding energy
    puts "#{x},#{y}: #{magnitude}"
    @gray_out_view[y][x] = Magick::Pixel.gray(val)
  end
end

@gray_out_view.sync
@gray.write("prewitt_ruby_out.jpg")
