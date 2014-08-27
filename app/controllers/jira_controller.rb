class CustomException < Exception
  attr_accessor :data
  def initialize(data)
    @data = data
  end
end

class JiraController < ApplicationController
  
  def performRequest (data)
    require 'net/http'
    require 'timeout'
    require 'logger'

    url = URI.parse(FiLabInfographics.jira + "/rest/api/2/issue/")
    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = FiLabInfographics.timeout
    http.read_timeout = FiLabInfographics.timeout
    
    req = Net::HTTP::Post.new(url.request_uri)
    req.body = data.to_json
    req.initialize_http_header({"Content-Type" => "application/json"})
    req.basic_auth(FiLabInfographics.jira_username, FiLabInfographics.jira_password)
    
    begin
      res = http.request(req)
    rescue Exception => e
        case e
          when Timeout::Error
            raise CustomException.new("timeout")
          when Errno::ECONNREFUSED
            raise CustomException.new("connection refused")
          when Errno::ECONNRESET
            raise CustomException.new("connection reset")
          when Errno::EHOSTUNREACH
            raise CustomException.new("host not reachable")
          else
            raise CustomException.new("error: #{e.to_s}")
        end
    end
# Logger.info('request');

#    res = Net::HTTP.start(url.host, url.port) { |http| 
#      http.request(req) 
#    } 
  
#     begin
#       res = Net::HTTP.start(url.host, url.port) {|http|
#       http.request(req)
#       }
#     rescue Net::OpenTimeout => e
# 	puts "-----------------"+e.message+"------------------------"
# 	raise e.message
#     end
#   Logger.error(data);   
    
    data = res.body  
    Rails.logger.info(data);
    begin
      result = JSON.parse(data)
    rescue Exception => e
      raise CustomException.new("Error parsing Data")
    end
       
    return result


 
    
#     return result ["queryContextResponse"] ["contextResponseList"]
    
  end
  
  def createIssue
    
#     params read
#     'region_id','type','priority','summary','description','email'
#     Rails.logger.info("THE REGION ID: "+params[:region_id]);
    
    jira_project_id = "XIFI"
    if(FiLabInfographics.jira_test == 0)
    
#       ---------------------------------------------
#       to set jira_project_id dinamically
#       ---------------------------------------------
      dbNode = Node.where(:rid => params[:region_id]).first
      if dbNode != nil
	jira_project_id = dbNode.jira_project_id;
      end
    end
      
    inputIssueData = Hash.new
    fields = Hash.new
    project_key = Hash.new
    project_key["key"] = jira_project_id #or id=10700
    parent_key = Hash.new
    parent_key["key"] = "XIFI-SUB" #or id=10700
    issuetype_id = Hash.new
    issuetype_id["id"] = params[:type]#1 is Bug,2 New Feature,3 is Task,4 Improvement,5 Sub-task,6 Epic,7 Story, 8 Technical task
    prioritytype_id = Hash.new
    prioritytype_id["id"] = params[:priority]#1 is Blocker,2 Critical,3 Major,4 Minor,5 Trivial
    fields["project"] = project_key
#     fields["parent"] = parent_key
    fields["summary"] = params[:summary]
    fields["description"] = params[:description]
    fields["issuetype"] = issuetype_id
    fields["priority"] = prioritytype_id
    fields["customfield_10301"] = params[:email]
    inputIssueData["fields"] = fields
    
    Rails.logger.info(inputIssueData);
    
    outputIssueData = self.performRequest(inputIssueData)
    
    render :json => outputIssueData.to_json
  end
  
end
