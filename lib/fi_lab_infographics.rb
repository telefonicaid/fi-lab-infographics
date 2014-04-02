module FiLabInfographics
  mattr_accessor :nodejs
  mattr_accessor :nodata
  @@nodejs = 'http://127.0.01:1336' 
  @@nodata = 'No Data'

  class << self
    def setup
      yield self
    end
  end
end
