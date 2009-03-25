class Blender
  
  # adds values in each channel, limiting to 255
  def self.add(base, blend)
    self.blend_images(base, blend) {|baseval,blendval| [baseval + blendval, 255].min}
  end
  
  # choose the maximum value
  def self.lighten(base,blend)
    self.blend_images(base, blend) {|baseval,blendval| [baseval, blendval].max}
  end
  
  # choose the minimum value
  def self.darken(base, blend)
    self.blend_images(base, blend) {|baseval,blendval| [baseval, blendval].min}
  end
  
  # effectively makes the base show through as much as the blend layer
  # has that channel's color.  so red from the base shows through as much
  # as the blend is red.  In general, stuff that's white in the blend layer
  # shows up normal in the base, and stuff that's dark in the blend layer
  # shows up darker in the base
  def self.multiply(base, blend)
    self.blend_images(base,blend) {|baseval, blendval| baseval * blendval / 255}
  end
  
  # difference blend two images
  def self.difference(base,blend)
    self.blend_images(base, blend) {|baseval, blendval| (baseval - blendval).abs}
  end
  
  # Reflect
  def self.reflect(base,blend)
    self.blend_images(base, blend) do |baseval, blendval|
      baseval == 255 ? 255 : [255, baseval * baseval / (255 - blendval)].min
    end
  end
  
  # Glow is the opposite of reflect
  def self.glow(base,blend)
    self.reflect(blend,base)
  end
  
  # Compare a set of arrays of pixels rather than two images
  def self.difference_pixels_with_pixels(base_pixels,blend_pixels)
    self.blend_pixels(base_pixels,blend_pixels) {|baseval, blendval| (baseval - blendval).abs }
  end
  
  # Iterates through large_image looking for most probable place for the small
  # image
  def self.find_by_difference_with_pixel_array(large_image,small_image)
    smallpix = small_image.all_pixels_as_arrays
    largepix = large_image.all_pixels_as_arrays
    diffmap = []
    minimum = nil
    0.upto(large_image.rows - small_image.rows - 1) do |lrg_row|
      0.upto(large_image.columns - small_image.columns - 1) do |lrg_column|
        diffnum = 0
        
        lrg_pixel_index = lrg_row * large_image.columns + lrg_column
        
        small_image.y_range.each do |sm_row|
          small_image.x_range.each do |sm_column|
            
            index_num_of_pixel_in_large_array = sm_row * large_image.columns + lrg_pixel_index + sm_column
            index_num_of_pixel_in_small_array = sm_row * small_image.columns + sm_column
            
            small_pixel = smallpix[ index_num_of_pixel_in_small_array ]
            large_pixel = largepix[ index_num_of_pixel_in_large_array ]
            diff = (small_pixel[0] - large_pixel[0]).abs + (small_pixel[1] - large_pixel[1]).abs +
                   (small_pixel[2] - large_pixel[2]).abs
            diffnum += diff
          end
        end
        minimum ||= diffnum
        if diffnum < minimum
          minimum = diffnum
          puts "***"
        end
        diffmap << diffnum
        puts "#{lrg_column},#{lrg_row}:#{diffnum}"
      end
    end
    diffmap
  end

  def self.blend_images(base, blend, yield_pixels=false, &blck)
    raise ArgumentError, "Images must have same dimensions" unless base.same_dimensions(blend)
    
    out_image = Image.new(base.columns, base.rows)
    out_pixels = self.blend_pixels(base.all_pixels, blend.all_pixels, yield_pixels, &blck)
    out_image.store_pixels(0,0,base.columns,base.rows,out_pixels)
  end
  
  def self.blend_images_by_pixel(base,blend,&blck)
    self.blend_images(base,blend,true,&blck)
  end

  # Blends pixel-by-pixel the +base_pixels+ and +blend_pixels+ arrays
  # Yield Pixel objects if +yield_pixels+ is true, otherwise yield
  # a tuple of [val1, val2] for each of the r,g,b channels
  def self.blend_pixels(base_pixels, blend_pixels, yield_pixels=false)
    out_pixels = []
    base_pixels.each_with_index do |pixel_base, idx|
      pixel_blend = blend_pixels[idx]
      
      if yield_pixels
        out_pixels << (yield [pixel_base, pixel_blend])
      else
        color_vals = [:red,:green,:blue].collect do |color| 
          yield [pixel_base.send(color), pixel_blend.send(color)]
        end
        out_pixels << Pixel.new(*color_vals)
      end
    end
    out_pixels
  end
  
  #######################################################################
  # The other find_by_difference_with_XXX methods are for benchmarking
  #######################################################################

  # for benchmarking purposes
  def self.difference_pixels_with_arrays(base_pixels,blend_pixels)
    self.blend_pixels(base_pixels,blend_pixels) do |pixel_base, pixel_blend|
      red     = (pixel_base[0] - pixel_blend[0]).abs
      green   = (pixel_base[1] - pixel_blend[1]).abs
      blue    = (pixel_base[2] - pixel_blend[2]).abs
      [red,green,blue]
    end
  end
  
  # for benchmarking purposes
  def self.find_by_difference_with_view(large_image, small_image)
    large_view = large_image.view(0,0,large_image.columns, large_image.rows)
    small_view = small_image.view(0,0,small_image.columns, small_image.rows)
    
    minimum = nil
    0.upto(large_image.rows - small_image.rows - 1) do |lrg_row|
      0.upto(large_image.columns - small_image.columns - 1) do |lrg_column|
        diffnum = 0
        small_image.y_range.each do |sm_row|
          small_image.x_range.each do |sm_column|
            small_pixel = small_view[sm_row][sm_column]
            large_pixel = large_view[lrg_row + sm_row][lrg_column + sm_column]
            diff = (small_pixel.red - large_pixel.red).abs +
                   (small_pixel.green - large_pixel.green).abs +
                   (small_pixel.blue - large_pixel.blue).abs
            diffnum += diff
          end
        end
        
        minimum ||= diffnum
        if diffnum < minimum
          minimum = diffnum
        end
      end
    end
  end
  
  # for benchmarking purposes
  def self.find_by_difference_with_get(large_image,small_image)
    minimum = nil
    diff_vals = []
    smallpix = small_image.get_pixels(0,0,small_image.columns, small_image.rows)
    0.upto(large_image.rows - small_image.rows - 1) do |row|
      0.upto(large_image.columns - small_image.columns - 1) do |column|
        largepix = large_image.get_pixels(column, row, small_image.columns, small_image.rows)
        diffpix  = self.difference_pixels_with_pixels(smallpix,largepix)
        diffnum = diffpix.inject(0) {|sum, pixel| sum += pixel.red + pixel.green + pixel.blue}
        minimum ||= diffnum
        # puts "#{column},#{row}:#{diffnum}"
        if diffnum < minimum
          # puts "*******"
          minimum = diffnum
        end
        diff_vals << diffnum
      end
    end
    return diff_vals
  end
  
  # for benchmarking purposes
  def self.find_by_difference_with_export(large_image, small_image)
    minimum = nil
    diff_vals = []
    smallpix = small_image.export_pixels_as_arrays(0,0,small_image.columns, small_image.rows)
    0.upto(large_image.rows - small_image.rows - 1) do |row|
      0.upto(large_image.columns - small_image.columns - 1) do |column|
        largepix = large_image.export_pixels_as_arrays(column, row, small_image.columns, small_image.rows)
        diffpix  = self.difference_pixels_with_arrays(smallpix,largepix)
        diffnum = diffpix.inject(0) {|sum, pixel| sum += pixel[0] + pixel[1] + pixel[2]}
        minimum ||= diffnum
        # puts "#{column},#{row}:#{diffnum}"
        if diffnum < minimum
          # puts "*******"
          minimum = diffnum
        end
        diff_vals << diffnum
      end
    end
    return diff_vals
  end
end