class Message < ActiveRecord::Base
  self.table_name = "fi_lab_infographics_messages"
  belongs_to :node, class_name: "Node", foreign_key: "node_id"
  belongs_to :owner, class_name: "FiLabApp::User", foreign_key: "user_id"
  
  
#   has_one :owner, class_name: "FiLabApp::User"
#   has_one :node, class_name: "Node"
end
