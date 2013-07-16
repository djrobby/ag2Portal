class SupplierContact < ActiveRecord::Base
  belongs_to :supplier
  attr_accessible :cellular, :department, :email, :extension, :first_name, :fiscal_id, :last_name, :phone, :position, :remarks

  has_paper_trail

  validates :first_name,          :presence => true
  validates :last_name,           :presence => true
end
