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
  
  def self.blend_images(base, blend)
    raise ArgumentError, "Images must have same dimensions" unless self.same_dimensions?(base,blend)
    
    out_pixels = []
    out_image = Image.new(base.columns, base.rows)
    
    blend_pixels = blend.all_pixels
    base.all_pixels.each_with_index do |pixel_base, idx|
      out_pixels << (yield [pixel_base, blend_pixels[idx]])
    end
    out_image.store_pixels(0,0,base.columns,base.rows,out_pixels)
  end
  
  def self.same_dimensions?(first,second)
    first.rows == second.rows && first.columns == second.columns
  end
end