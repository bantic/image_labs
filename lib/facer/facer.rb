class Facer
  def self.face_detector
    @@face_detector ||= 
      OpenCV::CvHaarClassifierCascade::load(
        File.dirname(__FILE__) + "/../../fixtures/haarcascade_frontalface_alt.xml"
      )
  end
  
  def self.cut_out_face(face_img)
    rm_img = face_img
    cv_img = OpenCV::IplImage.load(rm_img.filename)
    
    detector = self.face_detector
    face_rectangles = detector.detect_objects(cv_img)
    rect = face_rectangles.first
    
    rm_img.crop( rect.top_left.x, 
                 rect.top_left.y, 
                 (rect.bottom_right.x - rect.top_left.x),
                 (rect.bottom_right.y - rect.top_left.y) )
  end
  
  def self.split_up_face(face_img)
    height = face_img.rows / 3
    
    puts height
    
    width  = face_img.columns
    
    puts width
    
    top, middle, bottom = face_img.crop(0, 0, width, height),
                          face_img.crop(0, height, width, height),
                          face_img.crop(0, height *2, width, height)
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