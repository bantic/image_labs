require File.dirname(__FILE__) + "/../lib/lib"
require 'benchmark'

img = img(File.dirname(__FILE__) + "/../fixtures/cart_gray.jpg")
 
n = 10
Benchmark.bm do |x|
  x.report("two_d_array_with_view") { n.times do; ar = img.two_d_array_with_view; end }
  x.report("two_d_array_with_export_pixels") { n.times do; ar = img.two_d_array_with_export_pixels; end }
  x.report("two_d_array_with_dispatch") { n.times do; ar = img.two_d_array_with_dispatch; end }
  x.report("two_d_array_with_get_pixels") { n.times do; ar = img.two_d_array_with_get_pixels; end }
end

color = img(File.dirname(__FILE__) + "/../fixtures/color.jpg")
locations_array = []
0.upto(color.columns-1) do |column|
  0.upto(color.rows-1) do |row|
    locations_array << [column,row]
  end
end


Benchmark.bm do |x|
  x.report("manipulate_pixels_with_get_pixels") {
    color = img(File.dirname(__FILE__) + "/../fixtures/color.jpg")
    color.manipulate_pixels_with_get_pixels(locations_array) do |pixel|
      gray_val = (0.3 * pixel.red + 0.59 * pixel.green + 0.11 *pixel.blue)
      gray(gray_val)
    end
  }
  x.report("manipulate_pixels_with_export_pixels") {
    color = img(File.dirname(__FILE__) + "/../fixtures/color.jpg")
    color.manipulate_pixels_with_export_pixels(locations_array) do |pixel_array|
      gray_val = (0.3 * pixel_array[0] + 0.59 * pixel_array[1] + 0.11 * pixel_array[2])
      [gray_val, gray_val, gray_val]
    end
  }
  x.report("manipulate_pixels_with_view") {
    color = img(File.dirname(__FILE__) + "/../fixtures/color.jpg")
    color.manipulate_pixels_with_view(locations_array) do |pixel|
      gray_val = (0.3 * pixel.red + 0.59 * pixel.green + 0.11 *pixel.blue)
      gray(gray_val)
    end
  }
end

n=100
Benchmark.bmbm do |x|
  x.report("export_pixels_as_str") {
    n.times {
      color = Magick::ImageList.new(File.dirname(__FILE__) + "/../fixtures/color.jpg")
      color.export_pixels_to_str(0,0,color.columns,color.rows,"RGB").unpack("C*")
    }
  }
  x.report("export_pixels") {
    n.times {
      color = Magick::ImageList.new(File.dirname(__FILE__) + "/../fixtures/color.jpg")
      color.export_pixels(0,0,color.columns,color.rows,"RGB")
    }
  }
  x.report("get_pixels") {
    n.times {
      color = Magick::ImageList.new(File.dirname(__FILE__) + "/../fixtures/color.jpg")
      color.get_pixels(0,0,color.columns,color.rows)
    }
  }
  x.report("dispatch") {
    n.times {
      color = Magick::ImageList.new(File.dirname(__FILE__) + "/../fixtures/color.jpg")
      color.dispatch(0,0,color.columns,color.rows,"RGB")
    }
  }
  x.report("view") {
    n.times {
      color = Magick::ImageList.new(File.dirname(__FILE__) + "/../fixtures/color.jpg")
      color.view(0,0,color.columns,color.rows)
    }
  }
end

color           = Magick::ImageList.new(File.dirname(__FILE__) + "/../fixtures/color.jpg")
exported_pixels = color.export_pixels(0,0,color.columns,color.rows,"RGB")
getted_pixels   = color.get_pixels(0,0,color.columns,color.rows)
dispatched_pixels = color.dispatch(0,0,color.columns,color.rows,"RGB")

n=100

Benchmark.bmbm do |x|
  x.report("import_pixels") {
    n.times {
      i = Image.new(150,150)
      i.import_pixels(0,0,150,150,"RGB",exported_pixels)
    }
  }
  x.report("store_pixels") {
    n.times {
      i = Image.new(150,150)
      i.store_pixels(0,0,150,150,getted_pixels)
    }
  }
  x.report("constitute") {
    n.times {
      i = Image.constitute(150,150,"RGB",dispatched_pixels)
    }
  }
end