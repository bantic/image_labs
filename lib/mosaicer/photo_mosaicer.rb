require 'fileutils'

class PhotoMosaicer
  def initialize(image,source_images_dir,pixel_width=100,pixel_height=100,image_block_width=5,image_block_height=5)
    @source_images_dir = source_images_dir
    @input_image = image
    @pixel_width = pixel_width
    @pixel_height = pixel_height
    @image_block_width = image_block_width
    @image_block_height = image_block_height
    @intensities = []
    @image_hash = {}
  end
  
  def create_photo_mosaic!
    tmp_dir = "/tmp/pm-tmp"
    FileUtils.mkdir_p(tmp_dir)
    
    # Make all images the same size
    puts "rectifying images"
    Mosaicer.rectify_images(@source_images_dir, tmp_dir) do |img|
      print '.'
      img = img.crop_resized(@pixel_width, @pixel_height)
    end
    puts ""
    
    @scaled_images = ImageList.new(*Dir.glob(tmp_dir + "/*"))
    
    puts "calculating intensities"
    @scaled_images.each do |img|
      print '.'
      img_intensity = img.intensity
      @intensities << img_intensity
      @image_hash[img_intensity] = img
    end
    puts ""
    
    @intensities.sort!
    puts @intensities.inspect
    
    puts "Writing output image"
    output_image = Image.new((@input_image.columns / @image_block_width) * @pixel_width,
                             (@input_image.rows / @image_block_height) * @pixel_height)
    input_image_pixels = @input_image.two_d_array_of_pixels
    @input_image.y_range.each_slice(@image_block_height) do |row_array|
      @input_image.x_range.each_slice(@image_block_width) do |column_array|
        input_intensity = 0
        row_array.each do |row|
          column_array.each do |column|
            input_intensity += input_image_pixels[column][row].intensity
          end
        end
        input_intensity = input_intensity.to_f / (@image_block_height * @image_block_width)
        
        nearest_intensity = @intensities.detect {|intensity| input_intensity <= intensity} || @intensities.last
        nearest_intensity_image = @image_hash[nearest_intensity]

        x_offset = (column_array.first / @image_block_width) * @pixel_width
        y_offset = (row_array.first / @image_block_height) * @pixel_height
        
        output_image.composite!(nearest_intensity_image, x_offset, y_offset, Magick::OverCompositeOp)
      end
    end
    
    # clean up
    `rm -rf #{tmp_dir}`
    
    output_image
  end
end