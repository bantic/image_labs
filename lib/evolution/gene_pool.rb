class GenePool
  # A GenePool is made up of many Chromosomes,
  # and Chromosomes are made up of many genes.
  # Is this confusing nomenclature? Maybe.
  
  attr_accessor :chromosomes
  DEFAULT_POPULATION_SIZE=10

  def initialize(pop_size=DEFAULT_POPULATION_SIZE)
    @chromosomes = []
  end
end

