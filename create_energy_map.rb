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

0.upto(bottom) do |y|
  0.upto(right) do |x|
    
    puts "start #{x},#{y}:#{ energy(view[y][x])} (red: #{energy(view[y][x])})"
    
    base_energy = energy(view[y][x])
    
    if y == 0
      energy = base_energy
      puts "y == 0: energy = #{energy}"
    elsif x == 0 || x == right
      puts "edge"
      if x == 0 # left edge, only two pixels below
        puts "left edge"
        puts "#{x},#{y-1}:#{energy(view[y-1][x])}"
        puts "#{x + 1},#{y-1}:#{energy(view[y-1][x+1])}"
        energy = base_energy + [    energy(view[y - 1][x    ]),
                                    energy(view[y - 1][x + 1])].min
      else      # right edge, only two pixels below
        puts "right edge"
        puts "#{x - 1},#{y-1}:#{energy(view[y-1][x-1])}"
        puts "#{x},#{y-1}:#{energy(view[y-1][x])}"
        energy = base_energy + [    energy(view[y - 1][x - 1]),
                                    energy(view[y - 1][x    ])].min
      end
    else # not an edge, check all three pixels below
      puts "\t#{x-1},#{y-1}: #{energy(view[y - 1][x - 1])}"
      puts "\t#{x},#{y-1}: #{  energy(view[y - 1][x])}"
      puts "\t#{x+1},#{y-1}: #{energy(view[y - 1][x + 1])}"
      
      energy = base_energy + [    energy(view[y - 1][x - 1]),
                                  energy(view[y - 1][x    ]),
                                  energy(view[y - 1][x + 1])].min
    end
    
    puts "final energy for #{x},#{y}: #{energy}"
    energy = [255, energy].min # clip to 255
    view[y][x] = Magick::Pixel.new(energy, energy, energy)
    puts '#' * 30
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
