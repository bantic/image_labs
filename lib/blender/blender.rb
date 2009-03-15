class Blender
  def self.add(base, blend)
    self.blend_images(base, blend) do |pixel_base, pixel_blend|
      red     = [pixel_base.red + pixel_blend.red, 255].min
      green   = [pixel_base.green + pixel_blend.green, 255].min
      blue    = [pixel_base.blue  + pixel_blend.blue, 255].min
      Pixel.new(red,green,blue)
    end
  end
  
  def self.multiply(base, blend)
    self.blend_images(base, blend) do |pixel_base, pixel_blend|
      red     = pixel_base.red * pixel_blend.red / 255
      green   = pixel_base.green * pixel_blend.green / 255
      blue    = pixel_base.blue  * pixel_blend.blue / 255
      Pixel.new(red,green,blue)
    end
  end
  
  def self.difference(base,blend)
    self.blend_images(base, blend) do |pixel_base, pixel_blend|
      red     = (pixel_base.red - pixel_blend.red).abs
      green   = (pixel_base.green - pixel_blend.green).abs
      blue    = (pixel_base.blue  - pixel_blend.blue).abs
      Pixel.new(red,green,blue)
    end
  end
  
  def self.difference_pixels(base_pixels,blend_pixels)
    self.blend_pixels(base_pixels,blend_pixels) do |pixel_base, pixel_blend|
      red     = (pixel_base.red - pixel_blend.red).abs
      green   = (pixel_base.green - pixel_blend.green).abs
      blue    = (pixel_base.blue  - pixel_blend.blue).abs
      Pixel.new(red,green,blue)
    end
  end
  
  def self.find_by_difference(large_image,small_image)
    minimum = nil
    diff_vals = []
    smallpix = small_image.get_pixels(0,0,small_image.columns, small_image.rows)
    0.upto(large_image.rows - small_image.rows - 1) do |row|
      0.upto(large_image.columns - small_image.columns - 1) do |column|
        largepix = large_image.get_pixels(column, row, small_image.columns, small_image.rows)
        diffpix  = self.difference_pixels(smallpix,largepix)
        diffnum = diffpix.inject(0) {|sum, pixel| sum += pixel.red + pixel.green + pixel.blue}
        minimum ||= diffnum
        puts "#{column},#{row}:#{diffnum}"
        if diffnum < minimum
          puts "*******"
          minimum = diffnum
        end
        diff_vals << diffnum
      end
    end
    return diff_vals
  end
  
  def self.reflect(base,blend)
    self.blend_images(base, blend) do |pixel_base, pixel_blend|
      red     = pixel_base.red == 255 ? pixel_blend.red : [255, (pixel_base.red * pixel_base.red / (255 - pixel_blend.red))].min
      green     = pixel_base.green == 255 ? pixel_blend.green : [255, (pixel_base.green * pixel_base.green / (255 - pixel_blend.green))].min
      blue     = pixel_base.blue == 255 ? pixel_blend.blue : [255, (pixel_base.blue * pixel_base.blue / (255 - pixel_blend.blue))].min
      Pixel.new(red,green,blue)
    end
  end
  
  def self.glow(base,blend)
    self.reflect(blend,base)
  end
  
  def self.blend_images(base, blend, &blck)
    raise ArgumentError, "Images must have same dimensions" unless self.same_dimensions?(base,blend)
    
    out_image = Image.new(base.columns, base.rows)
    out_pixels = self.blend_pixels(base.all_pixels, blend.all_pixels, &blck)
    out_image.store_pixels(0,0,base.columns,base.rows,out_pixels)
  end
  
  def self.blend_pixels(base_pixels, blend_pixels)
    out_pixels = []
    base_pixels.each_with_index do |pixel_base, idx|
      out_pixels << (yield [pixel_base, blend_pixels[idx]])
    end
    out_pixels
  end
  
  def self.same_dimensions?(first,second)
    first.rows == second.rows && first.columns == second.columns
  end
end