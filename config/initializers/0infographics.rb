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

# Possible values (and visualizations) of node/service/check status:
# OK / NOT OK / PARTIALLY OK / NOT AVAILABLE
STATUS_OK  = 'green'
STATUS_NOK = 'red'
STATUS_POK = 'yellow'
STATUS_NA  = 'gray'
