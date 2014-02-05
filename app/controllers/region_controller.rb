class RegionController < ApplicationController
  
  def performRequest (uri)
    require 'net/http'

    url = URI.parse(FiLabInfographics.nodejs + "/" + uri)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    data = res.body
    
    result = JSON.parse(data)
#     return result ["queryContextResponse"] ["contextResponseList"]
    return result
  end
  
  def getRegions
    
#     regionsData = self.performRequest('region')
    regionsData = self.performRequest('monitoring/regions')
    
    idRegions = [] 
    
#     regionsData.each do |contextElementResponse|
#       contextElementResponse["contextElementResponse"].each do |contextElement|   
# 	contextElement["contextElement"].each do |entityId|
# 	  entityId["entityId"].each do |id|
# 	    id["id"].each do |idRegion|
# 	      idRegions.push(idRegion)
# 	    end
# 	  end
# 	end
#       end
#     end

    regionsData["_embedded"]["regions"].each do |region|
	      idRegions.push(region["id"])
    end
    
    totValues = Hash.new
    
    totValues["total_nb_users"] = regionsData["total_nb_users"];
    totValues["total_nb_cores"] = regionsData["total_nb_cores"];
    totValues["total_nb_ram"] = regionsData["total_nb_ram"];
    totValues["total_nb_disk"] = regionsData["total_nb_disk"];
    totValues["total_nb_vm"] = regionsData["total_nb_vm"];
    
    attributes = Hash.new
    
    idRegions.each do |idRegion|
      regionData = self.performRequest('monitoring/regions/' + idRegion)
      attributesRegion = Hash.new
      attributesRegion["id"] = regionData["id"]
      attributesRegion["name"] = regionData["name"]
      attributesRegion["country"] = regionData["country"]
      attributesRegion["latitude"] = regionData["latitude"]
      attributesRegion["longitude"] = regionData["longitude"]
      attributesRegion["nb_users"] = regionData["nb_users"]
      attributesRegion["nb_cores"] = regionData["nb_cores"]
      attributesRegion["nb_ram"] = regionData["nb_ram"]
      attributesRegion["nb_disk"] = regionData["nb_disk"]
      attributesRegion["nb_vm"] = regionData["nb_vm"]
      attributes[idRegion] = attributesRegion
    end
    
    totValues["total_regions_count"] = attributes.keys.count;
    
    returnData = Hash.new
    returnData ["regions"] = attributes;
    returnData ["tot"] = totValues;
    
    render :json => returnData.to_json
  end
  
  def getVms
    
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
    
    attributesRegionsVMs = Hash.new
    
    idRegions.each do |idRegion|
      regionData = self.performRequest('region/' + idRegion)
      
      locationVM = idRegion
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
      
      attributesVMs = Hash.new
      
      idVMs.each do |idVM|
	vmRegionData = self.performRequest('region/' + idRegion + '/VM/' + idVM)
      
	attributesVM = Hash.new

	vmRegionData.each do |contextElementResponse|
	  contextElementResponse["contextElementResponse"].each do |contextElement|
	    contextElement["contextElement"].each do |contextAttributeList|
	      contextAttributeList["contextAttributeList"].each do |contextAttribute|
		contextAttribute["contextAttribute"].each do |attribute|
		  attributesVM[attribute["name"].first] = attribute["contextValue"].first
		end
	      end
	    end
	  end
	end

	attributesVMs[idVM] = attributesVM

      end
      
      attributesRegionsVMs [locationVM] = attributesVMs
      
    end
    
    render :json => attributesRegionsVMs.to_json
      
  end
  
end