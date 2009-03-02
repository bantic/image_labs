require 'rubygems'
require 'RMagick'

img_name = "edges-small-inverted-crop.jpg"
img = Magick::ImageList.new(img_name)
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

puts "calculating energy values"
0.upto(bottom) do |y|
  0.upto(right) do |x|
    # puts "start #{x},#{y}:#{ energy(view[y][x])} (red: #{energy(view[y][x])})"
    
    base_energy = energy_array[y][x]
    
    if y == 0
      energy = base_energy
      # puts "y == 0: energy = #{energy}"
    elsif x == 0 || x == right
      # puts "edge"
      if x == 0 # left edge, only two pixels below
        # puts "left edge"
        # puts "#{x},#{y-1}:#{energy(view[y-1][x])}"
        # puts "#{x + 1},#{y-1}:#{energy(view[y-1][x+1])}"
        energy = base_energy + [    energy_array[y - 1][x    ],
                                    energy_array[y - 1][x + 1]].min
      else      # right edge, only two pixels below
        # puts "right edge"
        # puts "#{x - 1},#{y-1}:#{energy(view[y-1][x-1])}"
        # puts "#{x},#{y-1}:#{energy(view[y-1][x])}"
        energy = base_energy + [    energy_array[y - 1][x - 1],
                                    energy_array[y - 1][x    ]].min
      end
    else # not an edge, check all three pixels below
      # puts "\t#{x-1},#{y-1}: #{energy(view[y - 1][x - 1])}"
      # puts "\t#{x},#{y-1}: #{  energy(view[y - 1][x])}"
      # puts "\t#{x+1},#{y-1}: #{energy(view[y - 1][x + 1])}"
      
      energy = base_energy + [    energy_array[y - 1][x - 1],
                                  energy_array[y - 1][x    ],
                                  energy_array[y - 1][x + 1]].min
    end
    
    # puts "final energy for #{x},#{y}: #{energy}"
    # energy_array[y][x] = [255,energy].min
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
puts "normalizing values against max #{max_value}"
0.upto(bottom) do |y|
  0.upto(right) do |x|
#    energy_array[y][x] = [255, energy_array[y][x]].min # 
    energy_array[y][x] = ((energy_array[y][x] / max_value.to_f) * 255).to_i
  end
end


# write out values
puts "copying out energy values to view"
0.upto(bottom) do |y|
  0.upto(right) do |x|
    view[y][x] = Magick::Pixel.new(energy_array[y][x], energy_array[y][x], energy_array[y][x])
  end
end


view.sync
output_path = "energy_out.jpg"

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
