class GenePool
  # A GenePool is made up of many Chromosomes,
  # and Chromosomes are made up of many genes.
  # Is this confusing nomenclature? Maybe.
  
  attr_accessor :chromosomes, :generation
  DEFAULT_POPULATION_SIZE = 10
  DEFAULT_GENES_PER_CHROMOSOME = 5

  def initialize(pop_size=DEFAULT_POPULATION_SIZE, genes_per_chromosome=DEFAULT_GENES_PER_CHROMOSOME)
    @generation  = 1
    @chromosomes = []
    pop_size.times { @chromosomes << Chromosome.new(genes_per_chromosome) }
  end

  def evolve!(mutation_rate=0.01, cross_point=5)
    @chromosomes.sort!
    
    new_chromosomes = @chromosomes[0,5]
    5.upto(@chromosomes.size - 1) {new_chromosomes << Chromosome.new(DEFAULT_GENES_PER_CHROMOSOME)}

    @chromosomes = new_chromosomes
    
    @generation += 1
    return
    
    new_chromosomes[0] = @chromosomes[0]
    new_chromosomes[1] = @chromosomes[1]
    
    (2...(@chromosomes.size)).each_slice(2) do |idx1, idx2|
      mom, dad = naturally_select_two
      child1 = Chromosome.crossover(mom,dad,cross_point)
      child2 = Chromosome.crossover(dad,mom,cross_point)
      child1.mutate!(mutation_rate)
      child2.mutate!(mutation_rate)
      new_chromosomes[idx1] = child1
      new_chromosomes[idx2] = child2
    end
    
    @chromosomes = new_chromosomes
    
    @generation += 1
  end
  
  def debug
    
  end

  # ranked-roulette. See http://www.slideshare.net/inscit2006/parametric-study-to-enhance-genetic-algorithms-performance-using-ranked-based-roulette-wheel-selection-method
  def naturally_select_two
    seed = rand(10)
    if seed < 5
      [@chromosomes[0], @chromosomes[1]]
    elsif seed < 8
      [@chromosomes[2], @chromosomes[3]]
    else
      [@chromosomes[4], @chromosomes[5]]
    end
  end
end

