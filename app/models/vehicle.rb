class Vehicle < ActiveRecord::Base
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :product
  attr_accessible :brand, :cost, :model, :name, :registration,
                  :organization_id, :company_id, :office_id, :product_id
  has_attached_file :image, :styles => { :original => "160x160>", :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/vehicle.png"

  has_many :work_order_vehicles

  has_paper_trail

  validates :registration,  :presence => true,
                            :length => { :minimum => 4, :maximum => 10 },
                            :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => [ :organization_id, :company_id ] }
  validates :name,          :presence => true
  validates :organization,  :presence => true

  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  before_destroy :check_for_dependent_records

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.registration.blank?
      full_name += self.registration
    end
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  searchable do
    text :name, :registration, :brand, :model
    string :name
    string :registration
    string :brand
    string :model
    integer :organization_id
    integer :company_id
    integer :office_id
    integer :product_id
  end

  private

  def check_for_dependent_records
    # Check for work order vehicles
    if work_order_vehicles.count > 0
      errors.add(:base, I18n.t('activerecord.models.vehicle.check_for_work_orders'))
      return false
    end
  end
end
