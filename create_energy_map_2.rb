require 'rubygems'
require 'RMagick'
require 'pp'

img_name = "images/edges-small-inverted-crop40x40"
img = Magick::ImageList.new(img_name + ".jpg")
view = img.view(0,0,img.rows,img.columns)

right = img.columns - 1
bottom = img.rows - 1

def energy(pixel)
  pixel.red
#  255 - pixel.red
end

energy_array = Array.new(img.rows) {Array.new(img.columns)}

# copy initial energy values into 2d array
puts "copying initial energy values into 2d array"
0.upto(bottom) do |y|
  0.upto(right) do |x|
    energy_array[y][x] = energy(view[y][x])
  end
end

def wait_for_key
  return $stdin.gets
end

puts "calculating energy values"
0.upto(bottom) do |y|
  
  if y > 0
    # puts "#{y-1}: " + energy_array[y-1].collect{|int| sprintf("%5d",int)}.join("")
    # puts "#{y}: " + energy_array[y].collect{|int| sprintf("%5d",int)}.join("")
#    wait_for_key
  end
  
  0.upto(right) do |x|
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

# find max value
puts "calculating max value"
max_value = 0
0.upto(bottom) do |y|
  0.upto(right) do |x|
    max_value = [energy_array[y][x], max_value].max
  end
end

# normalize values
puts "copying normalized values into view max #{max_value}"
0.upto(bottom) do |y|
  0.upto(right) do |x|
    val = ((energy_array[y][x] / max_value.to_f) * 255).to_i
    view[y][x] = Magick::Pixel.new(val,val,val)
  end
end


# find the lowest energy value at each point
puts "finding seam"
min_pos = min_val = 0
0.upto(bottom) do |y|
  row_num = bottom - y
  if row_num == bottom
    min_val = energy_array[row_num].min
    min_pos = energy_array[row_num].index(min_val)
  else
    if min_pos == 0 || min_pos == right
      if min_pos == 0
        min_val = energy_array[row_num][min_pos, 2].min
        min_pos = energy_array[row_num][min_pos, 2].index(min_val) + min_pos
      else
        min_val = energy_array[row_num][min_pos - 1, 2].min
        min_pos = energy_array[row_num][min_pos - 1, 2].index(min_val) - 1 + min_pos
      end
    else
      min_val = energy_array[row_num][min_pos - 1, 3].min
      min_pos = energy_array[row_num][min_pos - 1, 3].index(min_val) - 1 + min_pos
    end
  end
  view[row_num][min_pos] = Magick::Pixel.new(255,0,0)
end

view.sync
output_path = "#{img_name}-energy_out-with-seam.jpg"

puts "processed file #{img_name} to #{output_path}"

img.write(output_path)

# 0.upto(right) do |x|
#   0.upto(bottom) do |y|
#     val = 255 - view[y][x].red
#     view[y][x] = Magick::Pixel.new(val,val,val)
#   end
# end
# 
# view.sync
# img.write("edges-inverted.jpg")
