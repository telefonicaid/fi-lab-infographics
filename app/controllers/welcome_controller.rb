class WelcomeController < ApplicationController
  
   def performRequest (uri)
    require 'net/http'

    url = URI.parse(FiLabInfographics.nodejs + "/" + uri)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    data = res.body
    
    result = JSON.parse(data)
    return result ["queryContextResponse"] ["contextResponseList"]
  end
  
  def index    
    @attributesRegions = "regions"
  end
  
  def vm    
    @attributesRegionsVms = "vms"
  end
  
  def status    
    @attributesRegionsServices = "status"
  end
  
end
