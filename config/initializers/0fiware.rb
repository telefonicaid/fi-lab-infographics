require_dependency 'fi_lab_app'

FiLabApp.setup do |config|
  # The domain this IdM in installed at
  #
  # config.domain    = 'account.lab.fi-ware.eu'

  # The servives available in the portal
  #
  # service level domain
  #config.services_name = ['cloud','store','mashup']
  #
  # title for the nav bar
  #config.services_title =  ['Cloud','Store','Mashup']
  #
  # css class for the nav bar
  #config.services_class = ['cloud','store','mashup']
  #
  # enable or disable help page link 
  # config.help_enable = 1
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

  # The sender of registration emails
  #
  # config.sender    = 'no-reply@account.lab.fi-ware.eu'

  # The name of the IdM
  # config.name      = "FI-Lab"

  # The logo of the IdM
  #
  # config.logo      = "FI-Lab.png"

  # Email address that will receive bug reports
  #
  # config.bug_receivers = [ 'admin@lab.fi-ware.eu' ]

  # List of email domains that are allowed to register
  # config.allowed_email_domains = %w( example.com other-example.com )
end

