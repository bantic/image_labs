require File.dirname(__FILE__) + '/lib.rb'
puts <<END
== RMagick Shell ==
#{Long_version}
===================
END

if Long_version =~ /Q16/
  puts <<-END
    [Warning] ImageMagick is compiled with Quantum Depth of 16, which may make
              some functions very slow, and cause tests to fail.
  END
end