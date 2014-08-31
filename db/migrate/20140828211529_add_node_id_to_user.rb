class AddNodeIdToUser < ActiveRecord::Migration
  def change
    add_column :fi_lab_app_users, :node_id, :integer
  end
end
