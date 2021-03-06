require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'
require 'fileutils'

describe EnergyMapper do
  before(:each) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end
  
  it "should make the correct output" do
    em = EnergyMapper.new(@fixtures_path + "/cart_edges.jpg")
    em.populate_energy_map!

    em.normalized_energy_map.should nearly_equal_image(@fixtures_path + "/cart_energy_map.jpg")
  end

  it "should find the seam correctly" do
    em = EnergyMapper.new(@fixtures_path + "/cart_edges.jpg")
    img = img(@fixtures_path + "/cart_edges.jpg")
    
    seam = em.find_seam!
    img.manipulate_pixels(seam) {|pix| Pixel.new(255,0,0)}
    img.should nearly_equal_image(@fixtures_path + "/cart_seam.gif")
  end
  
  it "should populate the energy map correctly by math" do
    image_array = [[1,2,3], 
                   [1,0,1], 
                   [2,1,0]] 
    
    energy_map = [[1,3,4],
                  [1,1,2],
                  [2,2,1]]
    EnergyMapper.populate_energy_map(image_array).should == energy_map
  end
  
  it "should find a seam correctly by math" do
    energy_map = [[1,2,3],
                  [2,3,2],
                  [3,0,1]]
                  
    EnergyMapper.find_seam(energy_map).should == [[2,2],[2,1],[1,0]]
  end
  
  after(:each) do
    `rm -rf #{@tmp_path}`
  end
  
end