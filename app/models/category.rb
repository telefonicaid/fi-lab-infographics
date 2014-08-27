class Category < ActiveRecord::Base
  self.table_name = "fi_lab_infographics_institution_categories"
  has_one :institution, class_name: "Institution"
#   belongs_to :institution, class_name: "Institution", foreign_key: "category_id"
end
