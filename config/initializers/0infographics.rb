require_dependency 'fi_lab_infographics'

FiLabInfographics.setup do |config|
  # Node.js proxy for monitoring
   config.nodejs = 'http://127.0.0.1:1336'
   config.timeout = 5
   config.nodata = 'No Data'

end
