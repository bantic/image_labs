class Facer
  def self.face_detector
    @@face_detector ||= 
      OpenCV::CvHaarClassifierCascade::load(
        File.dirname(__FILE__) + "/../../fixtures/haarcascade_frontalface_alt.xml"
      )
  end
  
  def self.put_funny_hat_on_celebrity(celebrity_img)
    rm_img = celebrity_img
    cv_img = OpenCV::IplImage.load(r_img.filename)
    
    detector = self.face_detector
    face_rectangles = detector.detect_objects(cv_img)
    
    face_rectangles.each do |rect|
      rect_w = rect.top_right.x - rect.top_left.x
      rect_h = rect.bottom_left.y  - rect.top_left.y
      
      hat = self.funny_hat.resize(rect_w.to_f * 0.8, rect_h.to_f * 0.8)
      
      x_offset = rect.top_left.x - (hat.columns.to_f * 0.1)
      y_offset = rect.top_left.y - (hat.rows.to_f * 0.95)
      rm_img.composite!(hat, x_offset, y_offset, Magick::OverCompositeOp)
    end
    rm_img
  end
  
  def self.funny_hat
    @hat ||= img(File.dirname(__FILE__) + "/../../fixtures/party-hat.png")
  end
end