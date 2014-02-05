require_dependency 'fi_lab_infographics'

FiLabInfographics.setup do |config|
  # Node.js proxy for monitoring
  config.nodejs = 'http://localhost:1339'

end
