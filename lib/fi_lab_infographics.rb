module FiLabInfographics
  mattr_accessor :nodejs
  mattr_accessor :timeout
  mattr_accessor :nodata
  mattr_accessor :jira
  mattr_accessor :jira_username
  mattr_accessor :jira_password
  mattr_accessor :jira_test
#   @@nodejs = 'http://192.168.1.100:80' 
  @@nodejs = 'http://193.205.211.69:1026' 
  @@timeout = 5
  @@nodata = 'No Data'
  @@jira = 'http://jira.fi-ware.org'
  @@jira_username = 'jira_username'
  @@jira_password = 'jira_password'
  @@jira_test = 1

  class << self
    def setup
      yield self
    end
  end
end
