require_dependency 'fi_lab_infographics'

FiLabInfographics.setup do |config|
  # Node.js proxy for monitoring
  config.nodejs = 'http://192.168.1.100:80'
  config.nodata = 'No Data'

end
