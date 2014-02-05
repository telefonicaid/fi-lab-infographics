require_dependency 'fi_lab_app'

FiLabApp.setup do |config|
  # The domain this app in installed at
  #
  # config.domain    = 'account.lab.fi-ware.eu'

  # The servives available in the portal
  #
  # service level domain
  config.services_name = []
  #
  # title for the nav bar
  #config.services_title =  ['Cloud','Store','Mashup']
  #
  # css class for the nav bar
  #config.services_class = ['cloud','store','mashup']
  #
  # enable or disable help page link 
  config.help_enable = 0
  #
  # define serivce level domain for help
  # config.help_name = ''
  #
  # define title for the help in the navigation bar
  # config.help_title = 'Help&info'
  #
  # define css class for help link
  # config.help_class = 'help' 


  # The subdomain of the portal: cloud, store, mashup
  #
  # config.subdomain = 'lab.fi-ware.eu'

  # enable or disable Google Analytics
  # config.ga = 0

  # Google Analytics code
  # config.gaCode = 'UA-xxxxxx-x'

  # The name of the App
  # config.appname      = "FI-Lab"

  # The logo of the App
  #
  # config.logo      = "FI-Lab.png"
end
