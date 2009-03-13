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
  
  def self.crossover(mom, dad, cross_point)
    self.new(mom.genes.size) do |chromosome|
      0.upto(mom.genes.size - 1) do |idx|
        chromosome.genes << (idx < cross_point ? mom.genes[idx] : dad.genes[idx])
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
  
  def mutate!(mutation_rate)
    # mutate each gene
    @genes.each {|gene| gene.mutate!(mutation_rate)}
    
    # swap genes, possibly
    if rand < mutation_rate
      first_pos = rand(@genes.size)
      second_pos = rand(@genes.size)
      
      @genes[first_pos], @genes[second_pos] = @genes[second_pos], @genes[first_pos]
    end
    @fitness = nil #reset fitness
  end
  
  # lower fitness is better
  def <=>(other)
    fitness <=> other.fitness
  end
  
  def fitness
    @fitness ||= Chromosome.mona_lisa.difference(render)[2]
  end
  
end