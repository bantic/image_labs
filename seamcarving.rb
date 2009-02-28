require 'rubygems'
require 'RMagick'

@path = "smalltest.jpg"
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

def x_mask(i,j)
  X_MASK[i + 1][j + 1]
end

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
      [-1,0,1].each do |i|
        [-1,0,1].each do |j|
          # can use .red since all pixel values are the same since we are grayscale
          xsum += @gray_view[y + j][x + i].red * x_mask(j,i)
          ysum += @gray_view[y + j][x + i].red * y_mask(j,i)
        end
      end
    end
    
    magnitude = xsum.abs + ysum.abs
    magnitude = [magnitude, 255].min # cap at 255
    
    val = 255 - magnitude
    puts "#{x},#{y}: #{magnitude}"
    @gray_out_view[y][x].red = @gray_out_view[y][x].green = @gray_out_view[y][x].blue = val
  end
end

@gray_out_view.sync
@gray.write("out.jpg")
