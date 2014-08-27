# This migration comes from fi_lab_app (originally 20140725135939)
class CreateFiLabAppRoles < ActiveRecord::Migration
  def change
    create_table :fi_lab_app_roles do |t|
      t.string :name
      t.string :rid

      t.timestamps
    end
  end
end
