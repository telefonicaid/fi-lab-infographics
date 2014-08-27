module FiLabApp
  class Role < ActiveRecord::Base
    include FiLabApp::ActorRole
  end
end
