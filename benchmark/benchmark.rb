require File.dirname(__FILE__) + "/../lib/lib"
require 'benchmark'

img = img(File.dirname(__FILE__) + "/../fixtures/edge_input.jpg")
 
n = 10
Benchmark.bm do |x|
  x.report("two_d_array_with_view") { n.times do; ar = img.two_d_array_with_view; end }
  x.report("two_d_array_with_export_pixels") { n.times do; ar = img.two_d_array_with_export_pixels; end }
end
