require 'fileutils'

class PhotoMosaicer
  VERBOSE = true
  
  # If a source images dir is given, we will use those as pixels
  # Otherwise, we will use grayscale blocks as pixels
  attr_accessor :source_images_dir
  
  def initialize(image, pixel_size=100, image_block_size=10)
    @input_image = image

    @pixel_width = @pixel_height = pixel_size
    @image_block_width = @image_block_height = image_block_size
  end
  
  def intensity_for_image_portion(x_offset, y_offset, columns, rows)
    intensity = 0
    pixel_count = 0
    x_offset.upto(x_offset + columns - 1) do |column|
      y_offset.upto(y_offset + rows - 1) do |row|
        break if column >= input_image_pixels.size
        break if row    >= input_image_pixels.first.size
        
        intensity   += input_image_pixels[column][row].intensity
        pixel_count += 1
      end
    end
    intensity = intensity.to_f / (pixel_count)
  end
    
  def input_image_pixels
    @input_image_pixels ||= @input_image.two_d_array_of_pixels
  end
  
  # Draw a grid with the given +spacing+ onto this image
  # Default gridlines are 1 pixel black, but method takes a block
  # to define the gridlines.  For 100-pixel spacing w/ 3-pixel red gridlines:
  #   PhotoMosaicer.draw_grid(img, 100) do |gridline|
  #    gridline.stroke = 'red'
  #    gridline.stroke_width = 3
  #   end
  def self.draw_grid(img, spacing)
    draw = Draw.new
    if block_given?
      yield draw
    else
      draw.stroke = 'black'
      draw.stroke_width = 1
    end
    
    0.upto(img.columns/spacing) do |column|
      draw.line( column * spacing, 0, column * spacing, img.rows - 1)
    end
    
    0.upto(img.rows/spacing) do |row|
      draw.line( 0, row * spacing, img.columns - 1, row * spacing)
    end
    
    draw.draw(img)
    img
  end
  
  def normalize_source_images!
    # Make all images the same size
    puts "Normalizing source images" if VERBOSE
    Mosaicer.rectify_images(@source_images_dir, tmp_dir) do |img|
      print '.' if VERBOSE
      img = img.crop_resized(@pixel_width, @pixel_height)
    end
    puts "" if VERBOSE
  end
  
  def calculate_source_image_intensities!
    @scaled_images = ImageList.new(*Dir.glob(tmp_dir + "/*"))
    @intensities = []
    @image_hash = {}
    
    puts "Calculating intensities of source images" if VERBOSE
    @scaled_images.each do |img|
      print '.' if VERBOSE
      img_intensity = img.intensity
      @intensities << img_intensity
      @image_hash[img_intensity] = img
    end
    puts "" if VERBOSE
    
    @intensities.sort!
    puts @intensities.inspect
  end
  
  def create_photo_mosaic!
    # If there is no +source_images_dir+ we will use grayscale blocks as output
    if @source_images_dir
      create_tmp_dir!
      normalize_source_images!
      calculate_source_image_intensities!
    end    
    
    puts "Writing output image" if VERBOSE
    
    # Create an output image of the appropriate size
    output_image = Image.new((@input_image.columns.to_f / @image_block_width) * @pixel_width,
                             (@input_image.rows.to_f / @image_block_height) * @pixel_height)
    

    @input_image.x_range.each_slice(@image_block_width) do |column_array|
      @input_image.y_range.each_slice(@image_block_height) do |row_array|

        x_offset = (column_array.first / @image_block_width) * @pixel_width
        y_offset = (row_array.first / @image_block_height) * @pixel_height
        
        intensity = intensity_for_image_portion(x_offset, y_offset, @image_block_width, @image_block_height)
        
        if @intensities
          # Find the closest image in our hash of source images
          nearest_intensity = @intensities.detect {|i| intensity <= i} || @intensities.last
          nearest_intensity_image = @image_hash[nearest_intensity]
        else
          bg_color = "rgb(#{intensity},#{intensity},#{intensity})"
          nearest_intensity_image = Image.new(@pixel_height, @pixel_width) do
            self.background_color = bg_color
          end
        end
        
        output_image.composite!(nearest_intensity_image, x_offset, y_offset, Magick::OverCompositeOp)
      end
    end
    
    clean_up_tmp_dir!
    
    output_image
  end
  
  private
  def tmp_dir
    "/tmp/pm-tmp"
  end
  
  def create_tmp_dir!
    FileUtils.mkdir_p(tmp_dir)
  end
  
  def clean_up_tmp_dir!
    `rm -rf #{tmp_dir}` if tmp_dir
  end
end