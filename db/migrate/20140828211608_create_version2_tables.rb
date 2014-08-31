class CreateVersion2Tables < ActiveRecord::Migration
  def change
     
    create_table "fi_lab_infographics_nodes", force: true do |t|
      t.string   "rid"
      t.string   "name"
      t.string   "jira_project_url"
      t.string   "jira_project_id"
    end
  
    create_table "fi_lab_infographics_messages", force: true do |t|
      t.integer "user_id", null: false
      t.integer "node_id", null: true
      t.string  "message"
      t.datetime "created_at"
    end
  
    create_table "fi_lab_infographics_institutions", force: true do |t|
      t.integer  "category_id"
      t.string   "name"
      t.string   "logo"
    end
   
    create_table "fi_lab_infographics_institution_categories", force: true do |t|
      t.string   "name"
      t.string   "logo"
    end
    
    create_table "fi_lab_infographics_nodes_institutions", id: false, force: true do |t|
      t.integer "node_id", null: false
      t.integer "institution_id", null: false
    end

  end
end
