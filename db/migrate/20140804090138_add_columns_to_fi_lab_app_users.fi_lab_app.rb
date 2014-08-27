# This migration comes from fi_lab_app (originally 20140228074024)
class AddColumnsToFiLabAppUsers < ActiveRecord::Migration
  def change
    add_column :fi_lab_app_users, :provider, :string
    add_column :fi_lab_app_users, :uid, :string
    add_column :fi_lab_app_users, :token, :text
    add_column :fi_lab_app_users, :refresh_token, :text
  end
end
