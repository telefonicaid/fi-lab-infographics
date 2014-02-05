module FiLabInfographics
  mattr_accessor :nodejs
  @@nodejs = 'http://localhost:1339'


  class << self
    def setup
      yield self
    end
  end
end
