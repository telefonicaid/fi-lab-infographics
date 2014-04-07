module FiLabInfographics
  mattr_accessor :nodejs
  mattr_accessor :timeout
  mattr_accessor :nodata
  @@nodejs = 'http://127.0.0.1:1336' 
  @@timeout = 5
  @@nodata = 'No Data'

  class << self
    def setup
      yield self
    end
  end
end
