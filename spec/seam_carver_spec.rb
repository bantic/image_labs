require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'
require 'fileutils'


describe SeamCarver do
  before(:each) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end
  
  it "should carve a seam from an image" do
    img = img(@fixtures_path + "/white100x100-red-diagonal-line.gif")
    
    seam = []
    0.upto(99) {|i| seam << [i,i]} # diagonal seam

    carved = SeamCarver.carve_column(img, seam)
    carved.write(@tmp_path + "/white100x99.gif")
    (@tmp_path + "/white100x99.gif").should equal_image(@fixtures_path + "/white100x99.gif")
  end
  
  after(:each) do
    `rm -rf #{@tmp_path}`
  end
  
end
