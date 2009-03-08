class SeamCarver
  def self.carve_column(img, seam)
    columns = img.columns
    rows    = img.rows
    
    carved_img = Image.new(columns - 1, rows)
        pixels = img.get_pixels(0,0,columns,rows)
    
    puts pixels.size
    deleted_pixel_count = 0
    seam.each do |column, row|
      deleted_pixel = pixels.delete_at( row * columns + column - deleted_pixel_count)
      if deleted_pixel.nil?
        puts "failed to delete at column #{column}, row #{row}"
      else
        deleted_pixel_count += 1
      end
    end
    puts pixels.size
    carved_img.store_pixels(0,0, columns - 1, rows, pixels)
    carved_img
  end
end