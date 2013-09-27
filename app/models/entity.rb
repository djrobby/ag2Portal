class Entity < ActiveRecord::Base
  belongs_to :entity_type
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  attr_accessible :building, :cellular, :company, :email, :extension, :fax, :first_name, :fiscal_id,
                  :floor, :floor_office, :last_name, :phone, :street_name, :street_number, :town,
                  :entity_type_id, :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                  :created_by, :updated_by

  has_paper_trail

  validates :first_name,      :presence => true, :if => "company.blank?"
  validates :last_name,       :presence => true, :if => "company.blank?"
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 9 },
                              :uniqueness => true
  validates :street_type_id,  :presence => true
  validates :zipcode_id,      :presence => true
  validates :town_id,         :presence => true
  validates :province_id,     :presence => true
  validates :region_id,       :presence => true
  validates :country_id,      :presence => true
  validates :entity_type_id,  :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    self[:fiscal_id].upcase!
  end

  def full_name
    self.last_name + ", " + self.first_name
  end

  def to_label
    "#{fiscal_id} #{supplier_code} #{last_name} #{first_name}"
  end

  #
  # Records navigator
  #
  def to_first
    Entity.order("fiscal_id").first
  end

  def to_prev
    Entity.where("fiscal_id < ?", supplier_code).order("fiscal_id").last
  end

  def to_next
    Entity.where("fiscal_id > ?", supplier_code).order("fiscal_id").first
  end

  def to_last
    Entity.order("fiscal_id").last
  end

  searchable do
    text :first_name, :last_name, :company, :fiscal_id, :cellular, :phone, :email, :street_name
    string :company
    string :last_name
    string :first_name
    string :fiscal_id
  end
end
