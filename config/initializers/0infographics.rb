require_dependency 'fi_lab_infographics'

FiLabInfographics.setup do |config|
  # Node.js proxy for monitoring
#    config.nodejs = 'http://192.168.1.100:80'
#   config.nodejs = 'http://193.205.211.69:1026'
#   config.nodejs = 'http://127.0.0.1:1336'
#   config.nodejs = 'http://130.206.84.4:1028'
   config.nodejs = 'http://130.206.84.4:1027'

#   config.nodejs = 'http://10.0.64.4:1027'
   config.timeout = 5
   config.nodata = 'No Data'
   config.jira = 'http://jira.fi-ware.org'
   config.jira_username = 'ext-usr'
   config.jira_password = 'extUsrXiFi14'
   config.jira_test = 0
   config.jira_default_project = 'FIL'
   config.jira_success_message = 'Thanks for reporting your issue. You will receive a notification for every update to the issue.'
end
