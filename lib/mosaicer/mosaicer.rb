require 'fileutils'

class Mosaicer
  # Usage:
  # # Create a mosaic w/ 60x60 images, 15 columns, 10 pixels of padding, and only full rows
  # mc = Mosaicer.new("dir_filled_with_images", 60, 15, 10, true)
  # mosaic = mc.create_mosaic
  # mosaic.write("mosaic.jpg")
  def initialize(input_dir, tile_size, columns, padding=0, full_rows_only=false)
    @input_dir    = input_dir
    @image_width  = @image_height = tile_size
    @columns      = columns
    @padding      = padding
    @full_rows_only = full_rows_only
  end
  
  def create_mosaic
    tmp_dir = "/tmp/mc-tmp"
    FileUtils.mkdir_p(tmp_dir)
    
    # Make all images the same size and put a border on them
    Mosaicer.rectify_images(@input_dir, tmp_dir) do |img|
      img = img.crop_resized(@image_width, @image_height)
      img = img.border(1,1,"black")
    end
    
    source_images = ImageList.new(*Dir.glob("/tmp/mc-tmp/*"))
    mosaic = 
      Mosaicer.tile_images(source_images, 
                                 @columns,
                                 @padding, 
                                 @full_rows_only)
    
    `rm -rf #{tmp_dir}` # cleanup tmp dir
    
    return mosaic
  end
  
  # assumes images have equal widths and heights
  def self.tile_images(imagelist, columns, padding=0, full_rows_only=false)
    row_num = 0
    imagelist.each_slice(columns) do |image_row|
      break if image_row.size < columns && full_rows_only
      image_row.each_with_index do |image, col_num|
        x_offset = (image.columns + 2 * padding) * col_num
        y_offset = (image.rows + 2 * padding) * row_num
        
        image.page = Rectangle.new(image.columns,image.rows,x_offset,y_offset)
      end
      row_num += 1
    end
    
    return imagelist.mosaic
  end
  
  # Turns images all into the same size and width and puts them
  # in a temporary directory
  def self.rectify_images(input_dir, output_dir, &block)
    imgs = ImageList.new(*Dir.glob(File.expand_path(input_dir) + "/*"))
    FileUtils.mkdir_p(output_dir)
    
    imgs.each_with_index do |img, idx|
      img = yield img
      img.write(output_dir + "/#{ sprintf("%03d",idx)}.png")
    end
  end
end