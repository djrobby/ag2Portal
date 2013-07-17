class SupplierContact < ActiveRecord::Base
  belongs_to :supplier
  attr_accessible :cellular, :department, :email, :extension, :first_name, :fiscal_id, :last_name,
                  :phone, :position, :remarks, :supplier_id

  has_paper_trail

  validates :first_name,          :presence => true
  validates :last_name,           :presence => true

  before_validation :fields_to_uppercase

  searchable do
    text :first_name, :last_name, :fiscal_id, :cellular, :phone, :email
    string :last_name
    string :first_name
  end

  def fields_to_uppercase
    self[:fiscal_id].upcase!
  end

  def full_name
    self.last_name + ", " + self.first_name
  end
end
