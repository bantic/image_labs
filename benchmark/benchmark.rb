require File.dirname(__FILE__) + "/../lib/lib"
require 'benchmark'

img = img(File.dirname(__FILE__) + "/../fixtures/cart_gray.jpg")
 
n = 10
Benchmark.bm do |x|
  x.report("two_d_array_with_view") { n.times do; ar = img.two_d_array_with_view; end }
  x.report("two_d_array_with_export_pixels") { n.times do; ar = img.two_d_array_with_export_pixels; end }
  x.report("two_d_array_with_dispatch") { n.times do; ar = img.two_d_array_with_dispatch; end }
end

#
# view
# export pixels
# 
#

# Results
#
#       user     system      total        real
# two_d_array_with_view  4.050000   1.110000   5.160000 (  5.199948)
# two_d_array_with_export_pixels  0.510000   0.240000   0.750000 (  0.760364)
# two_d_array_with_dispatch  0.600000   0.240000   0.840000 (  0.849024)
#