# This migration comes from fi_lab_app (originally 20140729122546)
class AddNickNameToUsers < ActiveRecord::Migration
  def change
    add_column :fi_lab_app_users, :nickname, :string
  end
end
