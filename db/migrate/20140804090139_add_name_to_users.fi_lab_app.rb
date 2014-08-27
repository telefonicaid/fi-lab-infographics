# This migration comes from fi_lab_app (originally 20140725120914)
class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :fi_lab_app_users, :name, :string
  end
end
