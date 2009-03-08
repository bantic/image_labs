class SeamCarver
  def initialize(img_path)
    @img = img(img_path)
    
    if @img.gray?
      @gray_img = @img.dup
    else
      @gray_img = @img.quantize(256, Magick::GRAYColorspace)
    end
  end
  
  def carve_seam!
    puts "Finding edges"
    # @edge_img = Edg
  end
  
  def self.carve_column(img, seam)
    columns = img.columns
    rows    = img.rows
    
    pixels = img.get_pixels(0,0,columns,rows)
    
    # Every time we do call Array#delete_at, the array gets one item shorter,
    # and if we need to subtract that difference when addressing future pixels
    # We use +deleted_pixel_count+ to keep track.
    deleted_pixel_count = 0
    
    seam.each do |column, row|
      deleted_pixel = pixels.delete_at( row * columns + column - deleted_pixel_count)
      raise "Incorrect pixel coordinate [column #{column}, row #{row}]" if deleted_pixel.nil?
      deleted_pixel_count += 1
    end

    carved_img = Image.new(columns - 1, rows)
    carved_img.store_pixels(0,0, columns - 1, rows, pixels)
    carved_img
  end
end