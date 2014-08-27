# This migration comes from fi_lab_app (originally 20140729173840)
class CreateJoinTableFilabAppRoleOrganization < ActiveRecord::Migration
  def change
    create_table "fi_lap_app_roles_organizations", id: false, force: true do |t|
      t.integer "role_id", null: false
      t.integer "organization_id", null: false
    end
  end
end
