class EnergyMapper
  attr_accessor :energy_map
  
  def initialize(img_path)
    @img          = img(img_path)
    @img_array    = @img.two_d_array
  end
  
  def find_seam!
    populate_energy_map!
    @seam = EnergyMapper.find_seam(@energy_map)
  end
  
  def populate_energy_map!
    @energy_map = EnergyMapper.populate_energy_map(@img_array)
  end
  
  def wait_for_key
    return $stdin.gets
  end
  
  def self.populate_energy_map(img_array)
    energy_map = img_array
    
    height = img_array.size - 1
    width  = img_array.first.size - 1

    0.upto(height) do |y|

      if y > 0
        # puts "#{y-1}: " + energy_array[y-1].collect{|int| sprintf("%5d",int)}.join("")
        # puts "#{y}: " + energy_array[y].collect{|int| sprintf("%5d",int)}.join("")
        # wait_for_key
      end

      0.upto(width) do |x|
        base_energy = img_array[y][x]

        if y == 0               # first row. energy is just edge value.
          energy = base_energy
        elsif x == 0 || x == width
          if x == 0  # left edge, only two pixels below
            energy = base_energy +  [img_array[y - 1][x    ],
                                     img_array[y - 1][x + 1]].min
          else       # right edge, only two pixels below
            energy = base_energy +  [img_array[y - 1][x - 1],
                                     img_array[y - 1][x    ]].min
          end
        else          # not an edge, check all three pixels below
          energy   = base_energy +  [img_array[y - 1][x - 1],
                                     img_array[y - 1][x    ],
                                     img_array[y - 1][x + 1]].min
        end
        
        energy_map[y][x] = energy
      end
    end
    
    energy_map
  end
  
  def self.find_seam(energy_map)
    @seam = []
    
    height = energy_map.size - 1
    width  = energy_map.first.size - 1
    
    min_pos = min_val = 0
    0.upto(height) do |y|
      row_num = height - y
      if row_num == height  # bottom row, just find the minimum value
        min_val = energy_map[row_num].min
        min_pos = energy_map[row_num].index(min_val)
      else
        if min_pos == 0 || min_pos == width # at an edge, only search two spaces
          if min_pos == 0
            min_val = energy_map[row_num][min_pos, 2].min
            min_pos = energy_map[row_num][min_pos, 2].index(min_val) + min_pos
          else
            min_val = energy_map[row_num][min_pos - 1, 2].min
            min_pos = energy_map[row_num][min_pos - 1, 2].index(min_val) - 1 + min_pos
          end
        else                                     # find the minimum from the three spaces above this
          min_val = energy_map[row_num][min_pos - 1, 3].min
          min_pos = energy_map[row_num][min_pos - 1, 3].index(min_val) - 1 + min_pos
        end
      end
      @seam << [min_pos, row_num]
    end
    
    @seam
  end
  
  def normalize_energy_map_to_pixels
    pixels_out = Array.two_d_array(@img.columns, @img.rows)
    max = @energy_map.flatten.max
    @img.y_range.each do |y|
      @img.x_range.each do |x|
        pixels_out[y][x] = Magick::Pixel.gray( ((@energy_map[y][x] / max.to_f) * 255).to_i )
      end
    end
    
    pixels_out
  end
  
  def normalized_energy_map_image
    pixels = normalize_energy_map_to_pixels
    
    energy_map_image = @img.dup
    energy_map_image.store_pixels(0,0,@img.columns,@img.rows, pixels.flatten)
    energy_map_image
  end
  
end