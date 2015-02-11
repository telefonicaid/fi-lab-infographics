require_dependency 'fi_lab_infographics'

FiLabInfographics.setup do |config|
  # Node.js proxy for monitoring
#    config.nodejs = 'http://192.168.1.100:80'
   config.nodejs = 'http://193.205.211.69:1026'
   config.timeout = 5
   config.nodata = 'No Data'
   config.jira = 'http://jira.fi-ware.org'
   config.jira_username = 'jira_username'
   config.jira_password = 'jira_password'
   config.jira_test = 1
end
