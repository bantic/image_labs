require 'RMagick'

@path = "testimage.jpg"
@image = Magick::ImageList.new(@path)
@gray = @image.quantize(256, Magick::GRAYColorspace)
@gray_view = @gray.view(0,0,@gray.columns,@gray.rows)

1.upto(@gray.rows - 2) do |x|
  1.upto(@gray.columns - 2) do |y|
    val = (@gray_view[x+1][y+1].intensity + 
           @gray_view[x+1][y].intensity + 
           @gray_view[x+1][y-1].intensity - 
           @gray_view[x-1][y-1].intensity - 
           @gray_view[x-1][y].intensity - 
           @gray_view[x-1][y+1].intensity ).abs +
          (@gray_view[x+1][y+1].intensity + 
           @gray_view[x][y+1].intensity + 
           @gray_view[x-1][y+1].intensity - 
           @gray_view[x+1][y-1].intensity - 
           @gray_view[x][y-1].intensity - 
           @gray_view[x-1][y-1].intensity ).abs
    puts "#{x},#{y}: #{val}"
    @gray_view[x][y] = Magick::Pixel.new(val,val,val)
  end
end


@gray_view.write("out.jpg")
