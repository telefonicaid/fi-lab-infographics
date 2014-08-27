module FiLabApp
  class User < ActiveRecord::Base
    include FiLabApp::Actor
    belongs_to :node, class_name: "Node", foreign_key: "node_id"
#     has_one :node, class_name: "Node"
#     belongs_to :message, class_name: "Message", foreign_key: "user_id"
    has_one :message, class_name: "Message"
  end
end
