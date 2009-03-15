require File.dirname(__FILE__) + "/../lib/lib"
require 'benchmark'

n = 3
large = img(File.dirname(__FILE__) + "/../fixtures/white20x20.png")
small = img(File.dirname(__FILE__) + "/../fixtures/white3x3.png")
Benchmark.bm do |x|
  x.report("find_by_difference_with_view") {
    n.times {
      Blender.find_by_difference_with_view(large,small)
    }
  }
  x.report("find_by_difference_with_pixel_array") {
    n.times {
      Blender.find_by_difference_with_pixel_array(large,small)
    }
  }
  x.report("find_by_difference_with_get") {
    n.times {
      Blender.find_by_difference_with_get(large,small)
    }
  }
  x.report("find_by_difference_with_export") {
    n.times {
      Blender.find_by_difference_with_export(large,small)
    }
  }
end

# Results
#       user     system      total        real
# find_by_difference_with_view  0.680000   0.190000   0.870000 (  0.865860)
# find_by_difference_with_pixel_array  0.240000   0.090000   0.330000 (  0.334452)
# find_by_difference_with_get  0.260000   0.080000   0.340000 (  0.345665)
# find_by_difference_with_export  0.310000   0.140000   0.450000 (  0.446519)
