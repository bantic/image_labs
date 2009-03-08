class SeamCarver
  attr_accessor :base_img
  
  def initialize(img_path)
    @base_img = img(img_path)
    
    if @base_img.gray?
      @gray_img = @base_img.dup
    else
      @gray_img = @base_img.quantize(256, Magick::GRAYColorspace)
    end
  end
  
  def carve_seam!
    puts "Finding edges"
    @edge_img = EdgeDetector.new(@gray_img).detect_edges
    
    puts "Creating energy map"
    em = EnergyMapper.new(@edge_img)
    em.populate_energy_map!
    
    puts "Finding seam"
    seam = em.find_seam!
    
    @base_img.manipulate_pixels(seam) {|pix| Pixel.new(255 - pix.red, 255 - pix.green, 255 - pix.blue)}
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