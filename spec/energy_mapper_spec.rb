require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'
require 'fileutils'

describe EnergyMapper do
  before(:all) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end
  
  it "should make the correct output" do
    em = EnergyMapper.new(@fixtures_path + "/cart_edges.jpg")
    em.populate_energy_map!
    em.normalize_energy_map_to_pixels
    em.write_normalized_image(@tmp_path + "/output.jpg")
    (@tmp_path + "/output.jpg").should equal_image(@fixtures_path + "/cart_energy_map.jpg")
  end
  
  after(:all) do
    `rm -rf #{@tmp_path}`
  end
end