class Gene
  MAX_RGB   = 255
  MAX_ALPHA = 1.0
  MAX_DIM   = 200

  DEFAULT_MUTATION_RATE = 0.2

  ATTRS = [:r, :g, :b, :a, :x, :y, :w, :h]

  def initialize
    @hash = {}
    ATTRS.each do |key|
      @hash[key] = rand
    end
  end
  
  def phenotype
    [
     (@hash[:r] * MAX_RGB).to_i,
     (@hash[:g] * MAX_RGB).to_i,
     (@hash[:b] * MAX_RGB).to_i,
     (@hash[:a] * MAX_ALPHA).to_f,
     (@hash[:x] * MAX_DIM).to_i,
     (@hash[:y] * MAX_DIM).to_i,
     (@hash[:w] * MAX_DIM).to_i,
     (@hash[:h] * MAX_DIM).to_i
    ]
  end
  
  def magick_draw_obj
    pheno = phenotype
    d = Draw.new
    d.fill("rgba(#{pheno[0]},#{pheno[1]},#{pheno[2]},#{pheno[3]}")
    d.ellipse(pheno[4],pheno[5],pheno[6],pheno[7],0,360)
  end
  
  def mutate!(mutation_rate=DEFAULT_MUTATION_RATE)
    @hash.each_key do |attribute|
      @hash[attribute] = rand if rand < DEFAULT_MUTATION_RATE
    end
  end
end

