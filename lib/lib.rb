require 'rubygems'
require 'RMagick'
include Magick

require File.dirname(__FILE__) + "/helper_methods"

require File.dirname(__FILE__) + "/seamcarving/edge_detector"
require File.dirname(__FILE__) + "/seamcarving/grayscaler"
require File.dirname(__FILE__) + "/seamcarving/energy_mapper"
require File.dirname(__FILE__) + "/seamcarving/seam_carver"

require File.dirname(__FILE__) + "/metacompositing/meta_compositer"