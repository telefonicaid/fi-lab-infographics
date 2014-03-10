module FiLabInfographics
  mattr_accessor :nodejs
  mattr_accessor :nodata
  @@nodejs = 'http://192.168.1.100:80' 
  @@nodata = 'No Data'

  class << self
    def setup
      yield self
    end
  end
end
