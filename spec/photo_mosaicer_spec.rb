require File.dirname(__FILE__) + "/../lib/spec_helpers"
require 'spec'


describe PhotoMosaicer do
  before(:each) do
    dirname = File.dirname(__FILE__)
    @fixtures_path = dirname + "/../fixtures"
    @tmp_path = dirname + "/tmp"
    FileUtils.mkdir_p(@tmp_path)
  end

  describe "#intensity_for_image_portion" do
    it "should work" do
      img = img(@fixtures_path + "/half-black-half-white.png")
      pm = PhotoMosaicer.new(img)

      pm.intensity_for_image_portion(0,0,50,100).should == 0
      pm.intensity_for_image_portion(50,0,50,100).should == 255
      pm.intensity_for_image_portion(0,0,100,100).should == 255.to_f / 2
    end
  end
end
