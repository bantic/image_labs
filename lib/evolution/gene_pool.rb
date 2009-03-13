class GenePool
  # A GenePool is made up of many Chromosomes,
  # and Chromosomes are made up of many genes.
  # Is this confusing nomenclature? Maybe.
  
  attr_accessor :chromosomes, :generation
  DEFAULT_POPULATION_SIZE = 10
  DEFAULT_CHROMOSOME_COUNT = 5

  def initialize(pop_size=DEFAULT_POPULATION_SIZE, chromosome_count=DEFAULT_CHROMOSOME_COUNT)
    @generation  = 1
    @chromosomes = []
    if block_given?
      yield self
    else
      pop_size.times { @chromosomes << Chromosome.new(chromosome_count) }
    end
  end

  def evolve!(mutation_rate=0.05, cross_point=5)
    @chromosomes.sort!
    
    (2...(@chromosomes.size)).each_slice(2) do |idx1, idx2|
      mom, dad = naturally_select_two
      child1 = Chromosome.crossover(mom,dad,cross_point)
      child2 = Chromosome.crossover(dad,mom,cross_point)
      child1.mutate!(mutation_rate)
      child2.mutate!(mutation_rate)
      @chromosomes[idx1] = child1
      @chromosomes[idx2] = child2
    end
    
    @generation += 1
  end

  # ranked-roulette. See http://www.slideshare.net/inscit2006/parametric-study-to-enhance-genetic-algorithms-performance-using-ranked-based-roulette-wheel-selection-method
  def naturally_select_two
    [@chromosomes[0], @chromosomes[1]]
  end
end

