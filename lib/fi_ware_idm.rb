module FiWareIdm
  mattr_accessor :domain
  @@domain = 'account.lab.fi-ware.eu'

  mattr_accessor :services_name
  @@services_name = ['cloud','store','mashup']
 
  mattr_accessor :services_title
  @@services_title = ['Cloud','Store','Mashup']

  mattr_accessor :services_class
  @@services_class = ['cloud','store','mashup']
  
  mattr_accessor :help_enable
  @@help_enable = 1
 
  mattr_accessor :help_name
  @@help_name = ''

  mattr_accessor :help_title
  @@help_title = 'Help&info'

  mattr_accessor :help_class
  @@help_class = 'help' 

  mattr_accessor :subdomain
  @@subdomain = 'lab.fi-ware.eu'

  mattr_accessor :sender
  @@sender = 'no-reply@account.lab.fi-ware.eu'

  mattr_accessor :name
  @@name = "FI-LAB"

  mattr_accessor :logo
  @@logo = 'Fi-lab.png'

  mattr_accessor :bug_receivers
  @@bug_receivers = []

  mattr_accessor :support_email
  @@support_email = "support@lab.fiware.eu"

  mattr_accessor :allowed_email_domains
  @@allowed_email_domains = []

  class << self
    def setup
      yield self
    end
  end
end
