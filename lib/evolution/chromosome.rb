class Chromosome
  attr_accessor :genes
  DEFAULT_POPULATION_SIZE=10
  
  def self.mona_lisa
    ImageList.new("ml.jpg")
  end
  
  def initialize(pop_size=DEFAULT_POPULATION_SIZE)
    @genes = []
    pop_size.times {@genes << Gene.new }
  end
  
  def render
    img = Image.new(200,200) {self.background_color = 'black'}
    img.format = 'PNG'
    
    @genes.each do |gene|
      draw = gene.magick_draw_obj
      draw.draw(img)
    end
    
    img
  end
  
  def fitness
    Chromosome.mona_lisa.difference(render)
  end
  
end