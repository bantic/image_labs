class Gene
  attr_accessor :genotype
  MAX_RGB   = 255
  MAX_ALPHA = 1.0
  MAX_POS   = 200
  MAX_DIM   = 200

  DEFAULT_MUTATION_RATE = 0.05

  ATTRS = [:r, :g, :b, :a, :x, :y, :w, :h]

  def initialize
    @genotype = {}
    if block_given?
      yield self
    else
      ATTRS.each do |key|
        @genotype[key] = rand
      end
    end
  end
  
  def phenotype
    {
     :r => (@genotype[:r] * MAX_RGB).to_i,
     :g => (@genotype[:g] * MAX_RGB).to_i,
     :b => (@genotype[:b] * MAX_RGB).to_i,
     :a => (@genotype[:a] * MAX_ALPHA).to_f,
     :x => (@genotype[:x] * MAX_POS).to_i,
     :y => (@genotype[:y] * MAX_POS).to_i,
     :w => (@genotype[:w] * MAX_DIM).to_i,
     :h => (@genotype[:h] * MAX_DIM).to_i
    }
  end
  
  def dup
    Gene.new do |gene|
      gene.genotype = @genotype.dup
    end
  end
  
  # draw yourself onto the given image
  def render(img)
    pheno = phenotype
    d = Draw.new
    d.fill("rgba(#{pheno[:r]},#{pheno[:g]},#{pheno[:b]},#{pheno[:a]}")
    d.ellipse(pheno[:x],pheno[:y],pheno[:w],pheno[:h],0,360)
    d.draw(img)
    img
  end
  
  def mutate!(mutation_rate=DEFAULT_MUTATION_RATE)
    @genotype.each_key do |attribute|
      if rand < mutation_rate
        @genotype[attribute] = rand 
      end
    end
  end
end

