require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'
require 'fileutils'
require 'ruby-debug'

describe SeamCarver do
  before(:each) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end
  
  it "should carve a seam one way" do
    img = img(@fixtures_path + "/white100x100-red-diagonal-line-nw.gif")
    
    seam = []
    0.upto(99) {|i| seam << [99-i,99-i]} # diagonal seam
    
    carved = SeamCarver.carve_column(img, seam)
    carved.should nearly_equal_image(@fixtures_path + "/white99x100.gif")
  end

  it "should carve a seam another way" do
    img = img(@fixtures_path + "/white100x100-red-diagonal-line-nw.gif")
    
    seam = []
    0.upto(99) {|i| seam << [99-i,99-i]} # diagonal seam

    carved = SeamCarver.carve_column(img, seam)
    carved.should nearly_equal_image(@fixtures_path + "/white99x100.gif")
  end

  it "should carve an img taller than wide correctly" do
    img = img(@fixtures_path + "/white99x100-red-diagonal-line-nw.gif")
    
    seam = []
    0.upto(98) {|i| seam << [i,i+1]} # diagonal seam

    carved = SeamCarver.carve_column(img, seam)
    carved.should nearly_equal_image(@fixtures_path + "/white98x100.gif")
  end

  it "should carve an img wider than tall correctly" do
    img = img(@fixtures_path + "/white100x99-red-diagonal-line-nw.gif")
    
    seam = []
    0.upto(98) {|i| seam << [i+1,i]} # diagonal seam

    carved = SeamCarver.carve_column(img, seam)
    carved.should nearly_equal_image(@fixtures_path + "/white99x99.gif")
  end

  
  after(:each) do
    `rm -rf #{@tmp_path}`
  end
  
end
