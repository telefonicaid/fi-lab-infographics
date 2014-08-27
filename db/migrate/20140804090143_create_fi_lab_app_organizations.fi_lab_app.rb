# This migration comes from fi_lab_app (originally 20140729173151)
class CreateFiLabAppOrganizations < ActiveRecord::Migration
  def change
    create_table :fi_lab_app_organizations do |t|
      t.string :name
      t.integer :actorId
      t.integer :rid

      t.timestamps
    end
  end
end
