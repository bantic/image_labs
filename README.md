= Image Labs

A collection of image processing experiments done in Ruby.

== /bin/rmagicksh ==

This is a script to launch irb w/ all the image_labs libraries as well as some convenience functions included.

== SeamCarver

Includes code to do edge detection (with the Prewitt kernel), energy mapping, and seam carving. Located in /lib/seamcarver

== Blender

Includes code to do image blending a la photoshop's blending layers. Located in /lib/blender

== Mosaicer/PhotoMosaicer

Includes code to generate large photomosaics and tiled mosaics (using the RMagick #mosaic function) of thumbnails.

== Evolution

Includes code that implements a darwinian-style genetic algorithm to "evolve" images out of a random collection of polygons.
This code currently is too slow and often gets stuck in local minima.

== Facer

Interface to the ruby-opencv gem (see http://github.com/bantic/ruby-opencv for more info and installation instructions) to do face detection.
Has opencv gem as a dependency. If you're using /bin/rmagicksh, type '$ load_facer' to load this gem and the Facer class.

== Spec

There is moderate test coverage in /spec. Run the tests with $ spec spec/*

== Fixtures and Images

/fixtures includes image data used by the tests, and /images includes sample images to play with the code.