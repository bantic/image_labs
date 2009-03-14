class GenePool
  # A GenePool is made up of many Chromosomes,
  # and Chromosomes are made up of many genes.
  # Is this confusing nomenclature? Maybe.
  
  attr_accessor :chromosomes, :generation
  DEFAULT_POPULATION_SIZE = 10
  DEFAULT_GENES_PER_CHROMOSOME = 30

  def initialize(pop_size=DEFAULT_POPULATION_SIZE, genes_per_chromosome=DEFAULT_GENES_PER_CHROMOSOME)
    @generation  = 1
    @genes_per_chromosome = genes_per_chromosome
    @chromosomes = []
    @pop_size = pop_size
    @pop_size.times { @chromosomes << Chromosome.new(@genes_per_chromosome) }
  end

  def evolve!(mutation_rate=0.2, cross_rate=0.7)
    @chromosomes.sort!
    
    new_chromosomes = []
    
    new_chromosomes[0] = @chromosomes[0].dup
    new_chromosomes[1] = @chromosomes[1].dup
    
    (2...(@chromosomes.size)).each_slice(2) do |idx1, idx2|
      mom = naturally_select_one
      dad = naturally_select_one
      child1 = Chromosome.crossover(mom,dad,cross_rate)
      child2 = Chromosome.crossover(dad,mom,cross_rate)
      new_chromosomes[idx1] = child1.mutate(mutation_rate)
      new_chromosomes[idx2] = child2.mutate(mutation_rate)
    end
    
    @chromosomes = new_chromosomes
    
    @generation += 1
  end
  
  def debug
    @chromosomes.sort.each do |c|
      puts c.fitness
    end
    puts '---------------------------'
  end

  # ranked-roulette. See http://www.slideshare.net/inscit2006/parametric-study-to-enhance-genetic-algorithms-performance-using-ranked-based-roulette-wheel-selection-method
  def naturally_select_one
    seed = rand
    selection = []
    @chromosomes.each_with_index do |c,idx|
      if (2 * (@pop_size - idx).to_f / (@pop_size * (@pop_size + 1))) > seed
        return c.dup
      end
    end

    return @chromosomes[rand(@chromosomes.size)].dup
  end
end

