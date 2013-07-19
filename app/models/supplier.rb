class Supplier < ActiveRecord::Base
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  attr_accessible :fiscal_id, :name, :supplier_code,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :region_id, :country_id
  attr_accessible :activity_ids

  has_paper_trail

  validates :name,                :presence => true
  validates :supplier_code,       :presence => true,
                                  :length => { :minimum => 5 },
                                  :uniqueness => true
  validates :fiscal_id,           :presence => true,
                                  :length => { :minimum => 9 },
                                  :uniqueness => true
  validates :street_type_id,      :presence => true
  validates :zipcode_id,          :presence => true
  validates :town_id,             :presence => true
  validates :province_id,         :presence => true
  validates :region_id,               :presence => true
  validates :country_id,              :presence => true

  before_validation :fields_to_uppercase

  has_many :supplier_contacts
  def fields_to_uppercase
    self[:fiscal_id].upcase!
    self[:supplier_code].upcase!
  end

  def to_label
    "#{name} (#{supplier_code})"
  end

  #
  # Records navigator
  #
  def to_first
    Supplier.order("supplier_code").first
  end

  def to_prev
    Supplier.where("supplier_code < ?", supplier_code).order("supplier_code").last
  end

  def to_next
    Supplier.where("supplier_code > ?", supplier_code).order("supplier_code").first
  end

  def to_last
    Supplier.order("supplier_code").last
  end

  searchable do
    text :supplier_code, :name, :fiscal_id, :street_name, :phone, :cellular, :email
    string :supplier_code
  end
end
