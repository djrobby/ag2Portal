class Tool < ActiveRecord::Base
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :product
  attr_accessible :brand, :cost, :model, :name, :serial_no,
                  :organization_id, :company_id, :office_id, :product_id
  has_attached_file :image, :styles => { :original => "160x160>", :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/vehicle.png"

  has_many :work_order_tools

  has_paper_trail

  validates :serial_no,     :presence => true,
                            :uniqueness => { :scope => [ :organization_id, :company_id, :office_id ] }
  validates :name,          :presence => true
  validates :organization,  :presence => true

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.serial_no.blank?
      self[:serial_no].upcase!
    end
    if !self.name.blank?
      self[:name].upcase!
    end
    if !self.brand.blank?
      self[:brand].upcase!
    end
    if !self.model.blank?
      self[:model].upcase!
    end
    true
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.serial_no.blank?
      full_name += self.serial_no
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  searchable do
    text :name, :serial_no, :brand, :model
    string :name
    string :serial_no
    string :brand
    string :model
    integer :organization_id
    integer :company_id
    integer :office_id
    integer :product_id
  end

  private

  def check_for_dependent_records
    # Check for work order tools
    if work_order_tools.count > 0
      errors.add(:base, I18n.t('activerecord.models.tool.check_for_work_orders'))
      return false
    end
  end
end
