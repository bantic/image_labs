class EnergyMapper
  attr_accessor :energy_map
  
  def initialize(img_path_or_img)
    @img = case img_path_or_img
    when String
      img(img_path_or_img)
    else
      img_path_or_img
    end

    @img_array    = @img.two_d_array
  end
  
  def find_seam!
    populate_energy_map! unless @energy_map
    @seam = EnergyMapper.find_seam(@energy_map)
  end
  
  def populate_energy_map!
    @energy_map = EnergyMapper.populate_energy_map(@img_array)
  end
  
  def self.populate_energy_map(img_array)
    energy_map = img_array
    
    width = img_array.size - 1
    height  = img_array.first.size - 1

    0.upto(height) do |row|

      0.upto(width) do |column|
        base_energy = img_array[column][row]

        if row == 0               # first row. energy is just edge value.
          energy = base_energy
        elsif column == 0 || column == width
          if column == 0  # left edge, only two pixels below
            energy = base_energy +  [img_array[column    ][row - 1],
                                     img_array[column + 1][row - 1]].min
          else       # right edge, only two pixels below
            energy = base_energy +  [img_array[column - 1][row - 1],
                                     img_array[column    ][row - 1]].min
          end
        else          # not an edge, check all three pixels below
          energy   = base_energy +  [img_array[column - 1][row - 1],
                                     img_array[column    ][row - 1],
                                     img_array[column + 1][row - 1]].min
        end
        
        energy_map[column][row] = energy
      end
    end
    
    energy_map
  end
  
  def self.find_seam(energy_map)
    @seam = []
    
    # It's easier to manipulate the energy map row-by-row rather than
    # column-by-column, so transpose the energy map now
    energy_map = energy_map.transpose
    
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
          else # min_pos == width
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
    pixels_out = []
    max = @energy_map.flatten.max
    @img.y_range.each do |row|
      @img.x_range.each do |column|
        pixels_out << ((@energy_map[column][row] / max.to_f) * 255).to_i
      end
    end
    
    pixels_out
  end
  
  def normalized_energy_map
    pixels = normalize_energy_map_to_pixels
    
    energy_map_image = Image.new(@img.columns,@img.rows)
    energy_map_image.import_pixels(0,0,@img.columns,@img.rows,"I",pixels)
    energy_map_image
  end
  
  def write_normalized_energy_map(path)
    normalized_energy_map.write(path)
  end
  
end