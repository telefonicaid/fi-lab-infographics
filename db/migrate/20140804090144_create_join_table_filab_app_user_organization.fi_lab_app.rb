# This migration comes from fi_lab_app (originally 20140729173622)
class CreateJoinTableFilabAppUserOrganization < ActiveRecord::Migration
  def change
    create_table "fi_lap_app_users_organizations", id: false, force: true do |t|
      t.integer "user_id", null: false
      t.integer "organization_id", null: false
    end
  end
end
