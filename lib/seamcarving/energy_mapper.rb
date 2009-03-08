class EnergyMapper
  def initialize(img_path)
    @img = img(img_path)
    @energy_array = @img.two_d_array
  end
  
  def create_energy_map!
    @img.y_range.each do |y|

      if y > 0
        # puts "#{y-1}: " + energy_array[y-1].collect{|int| sprintf("%5d",int)}.join("")
        # puts "#{y}: " + energy_array[y].collect{|int| sprintf("%5d",int)}.join("")
        # wait_for_key
      end

      @img.x_range.each do |x|
        base_energy = energy_array[y][x]

        if y == 0
          energy = base_energy
        elsif x == 0 || x == right
          if x == 0 # left edge, only two pixels below
            energy = base_energy + [    energy_array[y - 1][x    ],
                                        energy_array[y - 1][x + 1]].min
          else      # right edge, only two pixels below
            energy = base_energy + [    energy_array[y - 1][x - 1],
                                        energy_array[y - 1][x    ]].min
          end
        else # not an edge, check all three pixels below
          energy = base_energy + [    energy_array[y - 1][x - 1],
                                      energy_array[y - 1][x    ],
                                      energy_array[y - 1][x + 1]].min
        end
        energy_array[y][x] = energy
        # puts '#' * 30
      end  
    end
  end

  def energy(pixel_value)
    pixel_value
  end
end