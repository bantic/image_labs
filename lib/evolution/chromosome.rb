class Chromosome
  attr_accessor :genes
  DEFAULT_POPULATION_SIZE=10
  
  def self.mona_lisa
    @@mona_lisa ||= ImageList.new(File.dirname(__FILE__) + "/../../images/mona_lisa.png")
  end
  
  def initialize(pop_size=DEFAULT_POPULATION_SIZE)
    @genes = []
    if block_given?
      yield self
    else
      pop_size.times {@genes << Gene.new }
    end
  end
  
  def self.crossover(mom, dad, cross_rate)
    cross_point = rand < cross_rate ? rand(mom.genes.size) : 0
    
    Chromosome.new(mom.genes.size) do |c|
      0.upto(mom.genes.size - 1) do |idx|
        c.genes << (idx < cross_point ? mom.genes[idx].dup : dad.genes[idx].dup)
      end
    end
  end
  
  def dup
    Chromosome.new do |c|
      @genes.each do |gene|
        c.genes << gene.dup
      end
    end
  end
  
  def render(img=nil)
    if img.nil?
      img = Image.new(200,200) {self.background_color = 'black'}
      img.format = 'PNG'
    end
    
    @genes.each do |gene|
      gene.render(img)
    end
    
    img
  end
  
  def mutate(mutation_rate)
    Chromosome.new do |c|
      @genes.each do |gene|
        gene.mutate!(mutation_rate)
        c.genes << gene.dup
      end
      
      # swap genes, possibly
      if rand < mutation_rate
        first_pos = rand(c.genes.size)
        second_pos = rand(c.genes.size)

        c.genes[first_pos], c.genes[second_pos] = c.genes[second_pos], c.genes[first_pos]
      end
    end
  end
  
  # lower fitness is better
  def <=>(other)
    fitness <=> other.fitness
  end
  
  def fitness
    @fitness ||= Chromosome.mona_lisa.difference(render)[1]
  end
  
end