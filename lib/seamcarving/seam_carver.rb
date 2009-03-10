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
  
  def self.create_animation(base_img_path, frames=50)
    1.upto(frames) do |idx|
      puts "#{idx}: #{base_img_path}"
      sc = SeamCarver.new(base_img_path)
      
      edge_img = sc.find_edge_img
      edge_img.write("edges/#{idx}.png")
      
      seam = sc.find_seam!(idx)
      sc.base_img.manipulate_pixels(seam) {|p| Pixel.new(255,0,0)}
      
      puts "Writing redlines"
      sc.base_img.write("redlines/#{idx}.png")
      
      puts "Writing carved"
      carved = SeamCarver.carve_column(img(base_img_path),seam)
      carved.write("carves/#{idx}.png")
      
      base_img_path = "carves/#{idx}.png"
    end
  end
  
  def find_edge_img
    puts "Finding edges"
    @edge_img ||= EdgeDetector.new(@gray_img).detect_edges
  end
  
  def find_seam!(idx=nil)
    edge_img = find_edge_img
    edge_img.write("edges/#{idx}.png")
    
    puts "Creating energy map"
    em = EnergyMapper.new(edge_img)
    em.populate_energy_map!
    em.write_normalized_energy_map("energy/#{idx}.png")
    
    puts "Finding seam"
    seam = em.find_seam!
  end
  
  def self.carve_column(img, seam)
    columns = img.columns
    rows    = img.rows
    
    pixels = img.two_d_array_of_pixels
    
    seam.each do |column, row|
      pixels[row].delete_at(column)
    end

    carved_img = Image.new(columns - 1, rows)
    carved_img.store_pixels(0,0, columns - 1, rows, pixels.flatten)
    carved_img
  end
  
  # TODO fix this, as it is likely faster than the Image#two_d_array_of_pixels method
  # def self.carve_column(img, seam)
  #   columns = img.columns
  #   rows    = img.rows
  #   
  #   pixels = img.get_pixels(0,0,columns,rows)
  #   
  #   # Every time we do call Array#delete_at, the array gets one item shorter,
  #   # and if we need to subtract that difference when addressing future pixels
  #   # We use +deleted_pixel_count+ to keep track.
  #   deleted_pixel_count = 0
  #   
  #   seam.each do |column, row|
  #     deleted_pixel = pixels.delete_at( row * columns + column - deleted_pixel_count)
  #     raise "Incorrect pixel coordinate [column #{column}, row #{row}]" if deleted_pixel.nil?
  #     deleted_pixel_count += 1
  #   end
  # 
  #   carved_img = Image.new(columns - 1, rows)
  #   carved_img.store_pixels(0,0, columns - 1, rows, pixels)
  #   carved_img
  # end
end