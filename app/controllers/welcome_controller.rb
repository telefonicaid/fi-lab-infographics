class WelcomeController < ApplicationController
  def index
    
#     require 'net/http'
# 
#     url = URI.parse('http://192.168.59.2:1337/region')
#     req = Net::HTTP::Get.new(url.path)
#     res = Net::HTTP.start(url.host, url.port) {|http|
#       http.request(req)
#     }
#     data = res.body
#     
#     result = JSON.parse(data)
    
    regionsData = self.performRequest('region')
    
    idRegions = [] 
    
    regionsData.each do |contextElementResponse|
      contextElementResponse["contextElementResponse"].each do |contextElement|   
	contextElement["contextElement"].each do |entityId|
	  entityId["entityId"].each do |id|
	    id["id"].each do |idRegion|
	      idRegions.push(idRegion)
	    end
	  end
	end
      end
    end
    
    @attributes = Hash.new
    @coreTot = 0
    @coreUsed = 0
    @vmTot = 0
    @vmUsed = 0
    @hdTot = 0
    @hdUsed = 0
    @ramTot = 0
    @ramUsed = 0
    
    idRegions.each do |idRegion|
      regionData = self.performRequest('region/' + idRegion)
      attributesRegion = Hash.new
      regionData.each do |contextElementResponse|
	contextElementResponse["contextElementResponse"].each do |contextElement|
	  contextElement["contextElement"].each do |contextAttributeList|
	    contextAttributeList["contextAttributeList"].each do |contextAttribute|
	      contextAttribute["contextAttribute"].each do |attribute|
		attributesRegion[attribute["name"].first] = attribute["contextValue"].first
		if attribute["name"].first == "coreTot" then
		   @coreTot += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "coreUsed" then
		   @coreUsed += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "vmTot" then
		   @vmTot += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "vmUsed" then
		   @vmUsed += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "hdTot" then
		   @hdTot += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "hdUsed" then
		   @hdUsed += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "ramTot" then
		   @ramTot += attribute["contextValue"].first.to_i
		elsif attribute["name"].first == "ramUsed" then
		   @ramUsed += attribute["contextValue"].first.to_i
		end
	      end
	    end
	  end
	end
      end
      @attributes[idRegion] = attributesRegion
    end
    
    if @coreTot == 0 then @corePerc = 0
    else @corePerc = @coreUsed * 100 / @coreTot
    end
    if @vmTot == 0 then @vmPerc = 0
    else @vmPerc = @vmUsed * 100 / @vmTot
    end
    if @hdTot == 0 then @hdPerc = 0
    else @hdPerc = @hdUsed * 100 / @hdTot
    end
    if @ramTot == 0 then @ramPerc = 0
    else @ramPerc = @ramUsed * 100 / @ramTot
    end
    
    @users = 0
    
    idRegions.each do |idRegion|
      vmsRegionData = self.performRequest('region/' + idRegion + '/VM')
      idVMs = [] 
    
      vmsRegionData.each do |contextElementResponse|
	contextElementResponse["contextElementResponse"].each do |contextElement|   
	  contextElement["contextElement"].each do |entityId|
	    entityId["entityId"].each do |id|
	      id["id"].each do |idVm|
		idVMs.push(idVm)
	      end
	    end
	  end
	end
      end
      
      idVMs.each do |idVM|
	vmRegionData = self.performRequest('region/' + idRegion + '/VM/' + idVM)
      
	vmRegionData.each do |contextElementResponse|
	  contextElementResponse["contextElementResponse"].each do |contextElement|
	    contextElement["contextElement"].each do |contextAttributeList|
	      contextAttributeList["contextAttributeList"].each do |contextAttribute|
		contextAttribute["contextAttribute"].each do |attribute|
		  if attribute["name"].first == "Current Users" then
		    @users += attribute["contextValue"].first.to_i
		  end
		end
	      end
	    end
	  end
	end
	
      end
      
      
    end
    
    @print = "ciao"
#     @print =  regionsJson.to_a
#     @regionsJson = contextResponseList ["contextElementResponse"]
    
#    Rails.logger.debug("ciao ciao")
    
#     @data = "ciao"
#     render "welcome/index"
		    
  end
  
  def performRequest (uri)
    require 'net/http'

    url = URI.parse("http://192.168.59.2:1337/" + uri)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    data = res.body
    
    result = JSON.parse(data)
    return result ["queryContextResponse"] ["contextResponseList"]
  end
end
 