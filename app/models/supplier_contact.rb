class SupplierContact < ActiveRecord::Base
  belongs_to :supplier
  attr_accessible :cellular, :department, :email, :extension, :first_name, :fiscal_id, :last_name,
                  :phone, :position, :remarks, :supplier_id

  has_paper_trail

  validates :first_name,  :presence => true
  validates :last_name,   :presence => true
  validates :supplier_id, :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name
  end

  searchable do
    text :first_name, :last_name, :fiscal_id, :cellular, :phone, :email
    string :last_name
    string :first_name
    string :supplier_id
  end
end
