require 'fileutils'

class SeamCarver
  attr_accessor :base_img, :edge_img
  
  def initialize(img_path)
    @base_img = img(img_path)
    
    if @base_img.gray?
      @gray_img = @base_img.dup
    else
      @gray_img = @base_img.quantize(256, Magick::GRAYColorspace)
    end
  end
  
  def self.create_animation(base_img_path, frames=50, redlines_path="redlines", carves_path="carves", edges_path="edges", energy_path="energy")
    FileUtils.mkdir_p(redlines_path)
    FileUtils.mkdir_p(carves_path)
    FileUtils.mkdir_p(edges_path)
    FileUtils.mkdir_p(energy_path)
    
    1.upto(frames) do |idx|
      puts "#{idx}: #{base_img_path}"
      sc = SeamCarver.new(base_img_path)
      
      edge_img = sc.find_edge_img
      edge_img.write("edges/#{idx}.png")
      
      seam = sc.find_seam!(idx)
      sc.base_img.manipulate_pixels(seam) {|p| Pixel.new(255,0,0)}
      
      puts "Writing redlines"
      sc.base_img.write(redlines_path + "/#{idx}.png")
      
      puts "Writing carved"
      carved = SeamCarver.carve_column(img(base_img_path),seam)
      carved.write(carves_path + "/#{idx}.png")
      
      base_img_path = carves_path + "/#{idx}.png"
    end
  end
  
  # do it by carving each image rather than recalculating edges each time
  def self.create_animation_faster(base_img_path, frames=50, redlines_path="redlines", carves_path="carves", edges_path="edges", energy_path="energy")
    FileUtils.mkdir_p(redlines_path)
    FileUtils.mkdir_p(carves_path)
    FileUtils.mkdir_p(edges_path)
    FileUtils.mkdir_p(energy_path)
    
    sc = SeamCarver.new(base_img_path)
    edge_img = sc.find_edge_img
    edge_img.write(edges_path + "/0.png")
    seam = sc.find_seam!(0)
    sc.base_img.manipulate_pixels(seam) {|p| Pixel.new(255,0,0)}
    sc.base_img.write(redlines_path + "/0.png")
    
    carved = SeamCarver.carve_column(img(base_img_path),seam)
    carved.write(carves_path + "/0.png")
    
    1.upto(frames) do |idx|
      puts "#{idx}: #{base_img_path}"
      sc = SeamCarver.new(base_img_path)
      
      sc.edge_img = SeamCarver.carve_column(img(edges_path + "/#{idx - 1}.png"),seam)
      sc.edge_img.write("edges/#{idx}.png")
      
      
      seam = sc.find_seam!(idx)
      sc.base_img.manipulate_pixels(seam) {|p| Pixel.new(255,0,0)}  # Create a red line
      
      puts "Writing redlines"
      sc.base_img.write(redlines_path + "/#{idx}.png")
      
      puts "Writing carved"
      carved = SeamCarver.carve_column(img(base_img_path),seam)
      carved.write(carves_path + "/#{idx}.png")
      
      base_img_path = carves_path + "/#{idx}.png"
    end
  end
  
  # TODO: Use Image#extent to rectify the carved images for animation purposes
  
  def find_edge_img
    puts "Finding edges"
    @edge_img ||= EdgeDetector.new(@gray_img).detect_edges
  end
  
  def find_seam!(idx=nil)
    edge_img = find_edge_img
    
    puts "Creating energy map"
    em = EnergyMapper.new(edge_img)
    em.populate_energy_map!
    em.write_normalized_energy_map("energy/#{idx}.png") unless idx.nil?
    
    puts "Finding seam"
    seam = em.find_seam!
  end
  
  def self.carve_column(img, seam)
    columns = img.columns
    rows    = img.rows
    
    # It's simpler to work with the array if it is transposed. That way we
    # can reference the pixels on a row-by-row basis, and also bring the pixels
    # back in to the image with the #store_pixels method
    pixels = img.two_d_array_of_pixels.transpose
    
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