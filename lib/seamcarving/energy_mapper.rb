class EnergyMapper
  def initialize(img_path)
    @img = img(img_path)
    @energy_array = @img.two_d_array
  end
  
  def populate_energy_map!
    @img.y_range.each do |y|

      if y > 0
        # puts "#{y-1}: " + energy_array[y-1].collect{|int| sprintf("%5d",int)}.join("")
        # puts "#{y}: " + energy_array[y].collect{|int| sprintf("%5d",int)}.join("")
        # wait_for_key
      end

      @img.x_range.each do |x|
        base_energy = @energy_array[y][x]

        if y == 0               # first row. energy is just edge value.
          energy = base_energy
        elsif x == 0 || x == @img.right
          if x == 0  # left edge, only two pixels below
            energy = base_energy +  [@energy_array[y - 1][x    ],
                                     @energy_array[y - 1][x + 1]].min
          else       # right edge, only two pixels below
            energy = base_energy +  [@energy_array[y - 1][x - 1],
                                     @energy_array[y - 1][x    ]].min
          end
        else          # not an edge, check all three pixels below
          energy   = base_energy +  [@energy_array[y - 1][x - 1],
                                     @energy_array[y - 1][x    ],
                                     @energy_array[y - 1][x + 1]].min
        end
        
        @energy_array[y][x] = energy
      end  
    end
    
    @energy_array
  end
  
  def normalize_energy_map_to_pixels
    @pixels_out = Array.two_d_array(@img.columns, @img.rows)
    max = @energy_array.flatten.max
    puts "copying normalized values into view max #{max}"
    @img.y_range.each do |y|
      @img.x_range.each do |x|
        @pixels_out[y][x] = Magick::Pixel.gray( ((@energy_array[y][x] / max.to_f) * 255).to_i )
      end
    end
  end
  
  def write_normalized_image(output_path="output.jpg")
    @img.store_pixels(0,0,@img.columns,@img.rows,@pixels_out.flatten)
    @img.write(output_path)
  end
  
end