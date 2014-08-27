module FiLabApp
  class Organization < ActiveRecord::Base
    include FiLabApp::ActorOrganization
  end
end
