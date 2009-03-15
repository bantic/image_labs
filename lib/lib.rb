require 'rubygems'
require 'RMagick'
include Magick

require File.dirname(__FILE__) + "/helper_methods"

# SeamCarver
require File.dirname(__FILE__) + "/seamcarver/edge_detector"
require File.dirname(__FILE__) + "/seamcarver/energy_mapper"
require File.dirname(__FILE__) + "/seamcarver/seam_carver"

# Mosaicer
require File.dirname(__FILE__) + "/mosaicer/mosaicer"
require File.dirname(__FILE__) + "/mosaicer/photo_mosaicer"

# ImageEvolution
require File.dirname(__FILE__) + "/evolution/chromosome"
require File.dirname(__FILE__) + "/evolution/gene"
require File.dirname(__FILE__) + "/evolution/gene_pool"

# ImageBlender
require File.dirname(__FILE__) + "/blender/blender"
