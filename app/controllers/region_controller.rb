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
      @@token = @@token.refresh!
      logger.info "new token: " + @@token.token
    end
    return @@token
  end
  
  def self.setToken(token)
    logger.info "setting token: " + token.token
    @@token=token
  end

  def initialize
    super # this calls ActionController::Base initialize
    
    if @@token==nil
      client = OAuth2::Client.new(FiLabApp.client_id, FiLabApp.client_secret,
        :site => FiLabApp.account_server, :authorize_url => FiLabApp.account_server + '/authorize', :token_url => FiLabApp.account_server + '/token')

      token = client.client_credentials.get_token
      logger.debug 'acquired token:' + token.token
 
      RegionController.setToken(token)
    end
  end

  #perform request to federation monitoring API
  def performRequest (uri)
    require 'net/http'
    require 'timeout'
    require 'logger'
    
    url = URI.parse(FiLabInfographics.nodejs + "/monitoring/" + uri)
    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = FiLabInfographics.timeout
    http.read_timeout = FiLabInfographics.timeout
    
    req = Net::HTTP::Get.new(url.request_uri)
    req.initialize_http_header({"Accept" => "application/json"})
    
    
    oauthToken = Base64.strict_encode64( RegionController.getToken.token )
#     //DECOMMENT IN ORDER TO USE OAUTH
    req.add_field("Authorization", "Bearer "+oauthToken)
    Rails.logger.debug(req.get_fields('Authorization'));
    Rails.logger.debug(req.get_fields('Accept'));
    Rails.logger.debug(url.request_uri);
    
    startTime=Time.now.to_i

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
      Rails.logger.info("\nTHE HTTP STATUS: "+res.code+"\nTHE DATA RESPONSE: "+data+"\n--------------\n")
#       raise CustomException.new("Error parsing Data")
      raise CustomException.new(data)
    end
    endTime=Time.now.to_i

    delta=endTime-startTime
    Rails.logger.info("duration: ");
    Rails.logger.info(delta)
      
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
      
      regionsData["_embedded"]["regions"].each do |region|
		idRegions.push(region["id"])
      end
      
      totValues = Hash.new
      
      totValues["total_nb_users"] = regionsData["total_nb_users"];
      totValues["total_nb_organizations"] = regionsData["total_nb_organizations"];
      totValues["total_nb_cores"] = regionsData["total_nb_cores"];
      totValues["total_nb_ram"] = regionsData["total_nb_ram"];
      totValues["total_nb_disk"] = regionsData["total_nb_disk"];
      totValues["total_nb_vm"] = regionsData["total_nb_vm"];
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
      attributesRegion["name"] = regionsData["name"]
      attributesRegion["country"] = regionsData["country"]
      attributesRegion["latitude"] = regionsData["latitude"]
      attributesRegion["longitude"] = regionsData["longitude"]
      attributesRegion["nb_users"] = regionsData["measures"][0]["nb_users"]
      attributesRegion["nb_cores"] = regionsData["measures"][0]["nb_cores"]
      attributesRegion["nb_ram"] = regionsData["measures"][0]["nb_ram"]
      attributesRegion["nb_disk"] = regionsData["measures"][0]["nb_disk"]
      attributesRegion["nb_vm"] = regionsData["nb_vm"]
      return attributesRegion
      
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
