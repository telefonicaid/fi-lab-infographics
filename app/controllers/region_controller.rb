require 'oauth2'
require 'time'
 
class CustomException < Exception
  attr_accessor :data
  def initialize(data)
    @data = data
  end
end

class RegionController < ApplicationController
  
  @@token = nil  

  def self.getToken
    if @@token.expired?
      begin

        basic_auth_header="Basic " + Base64.strict_encode64(FiLabApp.client_id+":"+FiLabApp.client_secret)


        client = OAuth2::Client.new(FiLabApp.client_id, FiLabApp.client_secret,
          :site => FiLabApp.account_server, :authorize_url => FiLabApp.account_server + '/oauth2/authorize', :token_url => FiLabApp.account_server + '/oauth2/token')

        #token = client.client_credentials.get_token

        token = client.password.get_token('sla.fiwareops@gmail.com', 'Fiware@2015', :headers => {'Authorization' => basic_auth_header })

        RegionController.setToken(token)
      rescue Exception => e
        logger.error e
      end
      logger.debug "new token: " + @@token.token
    end
    return @@token
  end
  
  def self.setToken(token)
    logger.debug "setting token: " + token.token
    @@token=token
  end

  def initialize
    super # this calls ActionController::Base initialize
    
    if @@token==nil
      begin
  
        basic_auth_header="Basic " + Base64.strict_encode64(FiLabApp.client_id+":"+FiLabApp.client_secret)
        

        client = OAuth2::Client.new(FiLabApp.client_id, FiLabApp.client_secret,
          :site => FiLabApp.account_server, :authorize_url => FiLabApp.account_server + '/oauth2/authorize', :token_url => FiLabApp.account_server + '/oauth2/token')

        #token = client.client_credentials.get_token
        token = client.password.get_token('federico.facca@create-net.org', 'chicco785', :headers => {'Authorization' => basic_auth_header })

        RegionController.setToken(token)
      rescue Exception => e
        logger.debug e
      end
    end
  end

  #perform request to federation monitoring API
  def performRequest (uri)
    require 'net/http'
    require 'timeout'
    require 'logger'
        
    if RegionController.getToken==nil
       raise CustomException.new("IDM service unavailable")
       return
    end
    
    url = URI.parse(FiLabInfographics.nodejs + "/monitoring/" + uri)
    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = FiLabInfographics.timeout
    http.read_timeout = FiLabInfographics.timeout
    
    req = Net::HTTP::Get.new(url.request_uri)
    req.initialize_http_header({"Accept" => "application/json"})
    
    
    oauthToken = Base64.strict_encode64( RegionController.getToken.token )
#     //DECOMMENT IN ORDER TO USE OAUTH
#     req.add_field("Authorization", "Bearer "+oauthToken)
#    Rails.logger.debug(req.get_fields('Authorization'));
#    Rails.logger.debug(req.get_fields('Accept'));
#    Rails.logger.debug(url.request_uri);
    
#    startTime=Time.now.to_i

    begin
      res = http.request(req)
    rescue Exception => e
        case e
          when Timeout::Error
            raise CustomException.new("timeout")
	    return
          when Errno::ECONNREFUSED
            raise CustomException.new("connection refused")
	    return
          when Errno::ECONNRESET
            raise CustomException.new("connection reset")
	    return
          when Errno::EHOSTUNREACH
            raise CustomException.new("host not reachable")
	    return
          else
            raise CustomException.new("error: #{e.to_s}")
	    return
        end
    end
    
#     if res.code == 503
#       raise CustomException.new(res.body)
#       return
#     end
    
    data = res.body   
    begin
      result = JSON.parse(data)
    rescue Exception => e
#      Rails.logger.info("\nTHE HTTP STATUS: "+res.code+"\nTHE DATA RESPONSE: "+data+"\n--------------\n")
#       raise CustomException.new("Error parsing Data")
      raise CustomException.new(data)
    end
#    endTime=Time.now.to_i

#    delta=endTime-startTime
#    Rails.logger.info("duration: ");
#    Rails.logger.info(delta)
      
    return result

  end
  
  #check and shift two map points too close 
  def checkLatLong (points)
    
    points.each do |regionToCheckKey,regionToCheck|
      points.each do |regionKey,region|
	if regionToCheck["id"] != region["id"]
	  if (regionToCheck["latitude"].to_f - region["latitude"].to_f).abs < 0.4
	    regionToCheck["latitude"] = regionToCheck["latitude"].to_f+0.5
	  end
	  if (regionToCheck["longitude"].to_f - region["longitude"].to_f).abs < 0.4
	    regionToCheck["longitude"] = regionToCheck["longitude"].to_f+0.5
	  end
	end
      end
    end
    
    return points
  end
  
  #get all general data and specific data about all regions 
  def getRegionsData
    
    begin
      totRegionsData = self.getRegionsTotData
    rescue CustomException => e
      raise e
      return
    end
    
    if totRegionsData != nil
      
      idRegions = totRegionsData["total_regions_ids"]
    
      attributes = Hash.new
    
      idRegions.each do |idRegion|
	begin
	  attributesRegion = self.getRegionsDataForNodeId(idRegion)
	rescue CustomException => e
	  raise e
	  return
	end
	
	attributes[idRegion] = attributesRegion
	
      end    
      
      attributes = checkLatLong (attributes);
      returnData = Hash.new
      returnData ["regions"] = attributes;
      returnData ["tot"] = totRegionsData;
      
      return returnData;
      
    end
    return nil
  end
  
  #render all general data and specific data about all regions 
  def renderRegions

    begin
      regionsData = self.getRegionsData
    rescue CustomException => e
      render :json=>"Problem in retrieving data for all nodes: "+e.data, :status => :service_unavailable
      return
    end
    
    
    if regionsData == nil
      render :json=>"Problem in retrieving data: no data", :status => :service_unavailable
      return
    end
    render :json => regionsData.to_json
  end
  
  #render all general data about regions 
  def renderRegionsTotData
    begin
      totRegionsData = self.getRegionsTotData
    rescue CustomException => e
      render :json=>"Problem in retrieving tot data for all regions : "+e.data, :status => :service_unavailable
      return
    end  
      
    render :json => totRegionsData.to_json
  end
  
  #get all general data about regions 
  def getRegionsTotData
    begin
      regionsData = self.performRequest('regions')
    rescue CustomException => e
      raise e
      return
    end
    
    
    if regionsData != nil
      idRegions = [] 
      
      if regionsData["_embedded"] != nil && regionsData["_embedded"]["regions"] != nil
	regionsData["_embedded"]["regions"].each do |region|
                  if (region["id"]!='Berlin' and region["id"]!='Karlskrona' and region["id"]!='Budapest' and region["id"]!='Lannion' and region["id"]!='Spain')
		    idRegions.push(region["id"])
                  end 
	end
      else
	raise CustomException.new("No data about regions")
	return
      end
      
      totValues = Hash.new
      
      totValues["total_nb_users"] = regionsData["total_nb_users"];
      totValues["total_nb_organizations"] = regionsData["total_nb_organizations"];
      totValues["total_nb_cores"] = regionsData["total_nb_cores"];
      totValues["total_nb_ram"] = regionsData["total_nb_ram"];
      totValues["total_nb_disk"] = regionsData["total_nb_disk"];
      totValues["total_nb_vm"] = regionsData["total_nb_vm"];
      totValues["total_ip_allocated"] = regionsData["total_ip_allocated"];
      totValues["total_ip_assigned"] = regionsData["total_ip_assigned"];
      totValues["total_ip"] = regionsData["total_ip"];
      totValues["total_regions_ids"] = idRegions;
      totValues["total_regions_count"] = idRegions.count;
      
      return totValues
      
    end
    return nil
  end
  
  #render specific data about one region
  def renderRegionsDataForRegion
    idNode = params[:nodeId]
    begin
      regionsData = self.getRegionsDataForNodeId(idNode)
    rescue CustomException => e
      render :json=>"Problem in retrieving data for region "+idNode+": "+e.data, :status => :service_unavailable
      return
    end
    
    render :json => regionsData.to_json
  end
  
  #get specific data about one region
  def getRegionsDataForNodeId (idNode)
    begin
      regionsData = self.performRequest('regions/' + idNode)
    rescue CustomException => e
      raise e
    end
    
    if regionsData != nil
            
      attributesRegion = Hash.new
      attributesRegion["id"] = regionsData["id"]
      if(regionsData["id"]=='Berlin2')
         attributesRegion["name"] = 'Berlin'
      elsif(regionsData["id"]=='Spain2')
         attributesRegion["name"] = 'Spain'
      elsif(regionsData["id"]=='Lannion2')
         attributesRegion["name"] = 'Lannion'
      elsif(regionsData["id"]=='Karlskrona2')
         attributesRegion["name"] = 'Karlskrona'
      elsif(regionsData["id"]=='Budapest2')
         attributesRegion["name"] = 'Budapest'
      else 
        attributesRegion["name"] = regionsData["name"]
      end

      attributesRegion["country"] = regionsData["country"]
      attributesRegion["latitude"] = regionsData["latitude"]
      attributesRegion["longitude"] = regionsData["longitude"]
      attributesRegion["timestamp"] = regionsData["measures"][0]["timestamp"]
      attributesRegion["nb_users"] = regionsData["measures"][0]["nb_users"]
      attributesRegion["nb_cores"] = regionsData["measures"][0]["nb_cores"]
      attributesRegion["nb_cores_used"] = regionsData["measures"][0]["nb_cores_used"]
      attributesRegion["nb_ram"] = regionsData["measures"][0]["nb_ram"]
      attributesRegion["percRAMUsed"] = regionsData["measures"][0]["percRAMUsed"]
      if(regionsData["measures"][0]["cpu_allocation_ratio"])
         attributesRegion["cpu_allocation_ratio"] = regionsData["measures"][0]["cpu_allocation_ratio"]
      else
         attributesRegion["cpu_allocation_ratio"] = 16.0
      end
      if(regionsData["measures"][0]["ram_allocation_ratio"])
         attributesRegion["ram_allocation_ratio"] = regionsData["measures"][0]["ram_allocation_ratio"]
      else
         attributesRegion["ram_allocation_ratio"] = 1.5
      end
      attributesRegion["nb_disk"] = regionsData["measures"][0]["nb_disk"]
      attributesRegion["percDiskUsed"] = regionsData["measures"][0]["percDiskUsed"]
      attributesRegion["ipTot"] = regionsData["measures"][0]["ipTot"]
      attributesRegion["ipAllocated"] = regionsData["measures"][0]["ipAllocated"]
      attributesRegion["ipAssigned"] = regionsData["measures"][0]["ipAssigned"]
      attributesRegion["nb_vm"] = regionsData["nb_vm"]
      #if (regionsData["id"]=="Berlin2")
      return attributesRegion
      #end
    end 
    return nil
  end
  
  #render specific data about services of one region
  def renderServicesForRegion
    idNode = params[:nodeId]
    begin
      services = self.getServicesForNodeId(idNode)
    rescue CustomException => e
      render :json=>"Problem in retrieving services for region "+idNode+": "+e.data, :status => :service_unavailable
      return
    end
    
    render :json => services.to_json
  end
  
  #get specific data about services of one region
  def getServicesForNodeId (idNode)    
    
    begin
      servicesRegionData = self.performRequest('regions/' + idNode + '/services')
    rescue CustomException => e
      raise e
    end
    
    serviceNova = Hash.new
    serviceNeutron = Hash.new
    serviceCinder = Hash.new
    serviceGlance = Hash.new
    serviceKP = Hash.new
    serviceOverall = Hash.new
    
    serviceNova["value"] = "gray";
    serviceNova["description"] = "";
    
    
    serviceNeutron["value"] = "gray";
    serviceNeutron["description"] = "";
    
    
    serviceCinder["value"] = "gray";
    serviceCinder["description"] = "";
    
    
    serviceGlance["value"] = "gray";
    serviceGlance["description"] = "";
    
    
    serviceKP["value"] = "gray";
    serviceKP["description"] = "";
    
    serviceOverall["value"] = "gray";
    serviceOverall["description"] = "No Messages";
    
    if servicesRegionData != nil &&  
	  servicesRegionData["measures"] != nil && 
	  servicesRegionData["measures"][0] != nil
      
      serviceRegionData = servicesRegionData["measures"][0]
      
      if serviceRegionData["novaServiceStatus"] != nil
	if serviceRegionData["novaServiceStatus"]["value"] != nil && serviceRegionData["novaServiceStatus"]["value"] != "undefined"
	  serviceNova["value"] = serviceRegionData["novaServiceStatus"]["value"];
	end
	if serviceRegionData["novaServiceStatus"]["description"] != nil 
	  serviceNova["description"] = serviceRegionData["novaServiceStatus"]["description"];
	end
      end
      
      if serviceRegionData["neutronServiceStatus"] != nil
	if serviceRegionData["neutronServiceStatus"]["value"] != nil && serviceRegionData["neutronServiceStatus"]["value"] != "undefined"
	  serviceNeutron["value"] = serviceRegionData["neutronServiceStatus"]["value"];
	end
	if serviceRegionData["neutronServiceStatus"]["description"] != nil
	  serviceNeutron["description"] = serviceRegionData["neutronServiceStatus"]["description"];
	end
      end
      
      if serviceRegionData["cinderServiceStatus"] != nil
	if serviceRegionData["cinderServiceStatus"]["value"] != nil && serviceRegionData["cinderServiceStatus"]["value"] != "undefined"
	  serviceCinder["value"] = serviceRegionData["cinderServiceStatus"]["value"];
	end
	if serviceRegionData["cinderServiceStatus"]["description"] != nil
	  serviceCinder["description"] = serviceRegionData["cinderServiceStatus"]["description"];
	end
      end
      
      
      if serviceRegionData["glanceServiceStatus"] != nil
	if serviceRegionData["glanceServiceStatus"]["value"] != nil && serviceRegionData["glanceServiceStatus"]["value"] != "undefined"
	  serviceGlance["value"] = serviceRegionData["glanceServiceStatus"]["value"];
	end
	if serviceRegionData["glanceServiceStatus"]["description"] != nil
	  serviceGlance["description"] = serviceRegionData["glanceServiceStatus"]["description"];
	end
      end
      
      
      if serviceRegionData["KPServiceStatus"] != nil
	if serviceRegionData["KPServiceStatus"]["value"] != nil && serviceRegionData["KPServiceStatus"]["value"] != "undefined"
	  serviceKP["value"] = serviceRegionData["KPServiceStatus"]["value"];
	end
	if serviceRegionData["KPServiceStatus"]["description"] != nil
	  serviceKP["description"] = serviceRegionData["KPServiceStatus"]["description"];
	end
      end
      
      
      if serviceRegionData["OverallStatus"] != nil
	if serviceRegionData["OverallStatus"]["value"] != nil && serviceRegionData["OverallStatus"]["value"] != "undefined"
	  serviceOverall["value"] = serviceRegionData["OverallStatus"]["value"];
	end
	if serviceRegionData["OverallStatus"]["description"] != nil
	  serviceOverall["description"] = serviceRegionData["OverallStatus"]["description"];
	end
      end
      
    end
    
    services = Hash.new
    services["Nova"] = serviceNova;
    services["Neutron"] = serviceNeutron;
    services["Cinder"] = serviceCinder;
    services["Glance"] = serviceGlance;
    services["Keystone P."] = serviceKP;
    services["overallStatus"] = serviceOverall;
    
    
    dbNode = Node.where(:rid => idNode).first
    if dbNode != nil
      services["overallStatus"]["jira_project_url"] = dbNode.jira_project_url;
    end   
    
    return services
    
  end
  
  #render data about services of all regions
  def renderServices
    
    begin
      regionsData = self.getRegionsData
    rescue CustomException => e
      render :json=>"Problem in retrieving data for all nodes: "+e.data, :status => :service_unavailable
      return
    end
    
    if regionsData == nil
      render :json=>"Problem in retrieving data: no data", :status => :service_unavailable
      return
    end
    
    attributesRegionsServices = regionsData["regions"]
    
    
    attributesRegionsServices.each do |key,regionData|
      
      begin
	services = self.getServicesForNodeId(regionData["id"])
      rescue CustomException => e
	render :json=>"Problem in retrieving services for region "+regionData["id"]+": "+e.data, :status => :service_unavailable
	return
      end
      
      regionData["services"] = services;
      
      
#       attributesRegionsServices[regionData["id"]]["Nova"]["value"] = serviceRegionData["novaServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Nova"]["description"] = serviceRegionData["novaServiceStatus"]["description"];
      
#       attributesRegionsServices[regionData["id"]]["Neutron"]["value"] = serviceRegionData["neutronServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Neutron"]["description"] = serviceRegionData["neutronServiceStatus"]["description"];

#       attributesRegionsServices[regionData["id"]]["Cinder"]["value"] = serviceRegionData["cinderServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Cinder"]["description"] = serviceRegionData["cinderServiceStatus"]["description"];
      
#       attributesRegionsServices[regionData["id"]]["Glance"]["value"] = serviceRegionData["glanceServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Glance"]["description"] = serviceRegionData["glanceServiceStatus"]["description"];
      
#       attributesRegionsServices[regionData["id"]]["IDM"]["value"] = serviceRegionData["KPServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["IDM"]["description"] = serviceRegionData["KPServiceStatus"]["description"];
      
#       points = 0
#       if serviceRegionData["novaServiceStatus"]["value"] == "green"
# 	points+=2;
#       end
# 	
#       if serviceRegionData["neutronServiceStatus"]["value"] == "green"
# 	points+=2;
#       end
# 	
#       if serviceRegionData["cinderServiceStatus"]["value"] == "green"
# 	points+=2;
#       end
# 	
#       if serviceRegionData["glanceServiceStatus"]["value"] == "green" 
# 	points+=2;
#       end
# 	
#       if serviceRegionData["KPServiceStatus"]["value"] == "green" 
# 	points+=2;
#       end
# 	
#       if points == 10 
# 	attributesRegionsServices[regionData["id"]]["services"]["overallStatus"] = "green";
#       elsif points <= 5 
# 	attributesRegionsServices[regionData["id"]]["services"]["overallStatus"] = "red";
#       elsif 
# 	attributesRegionsServices[regionData["id"]]["services"]["overallStatus"] = "yellow";
#       end

    end
#     puts attributesRegionsServices
    render :json => attributesRegionsServices.to_json
      
  end
  
  def renderRegionIdListFromDb
    
    allDbNodes = Node.order(:rid).all
    allNodes = Array.new;
    if !allDbNodes.nil?
      allDbNodes.each do |singleNode|
	allNodes.push singleNode.rid;
      end
    end
    
    nodesList = Hash.new
    nodesList["list"] = allNodes;
    nodesList["successMsg"] = FiLabInfographics.jira_success_message;
    render :json => nodesList.to_json
    
  end
  
  def renderVms
    
    regionsData = self.performRequest('regions')
    
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
	vmRegionData = self.performRequest('regions/' + idRegion + '/VM/' + idVM)
      
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
