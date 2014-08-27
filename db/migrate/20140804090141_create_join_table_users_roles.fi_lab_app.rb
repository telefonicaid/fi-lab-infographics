# This migration comes from fi_lab_app (originally 20140725142620)
class CreateJoinTableUsersRoles < ActiveRecord::Migration
  def change
    create_table :fi_lap_app_users_roles, :id => false  do |t|
      t.integer :user_id, :null => false
      t.integer :role_id, :null => false
    end
  end
end
