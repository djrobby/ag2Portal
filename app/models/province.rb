class Province < ActiveRecord::Base
  belongs_to :region
  attr_accessible :ine_cpro, :name, :region_id,
                  :created_by, :updated_by

  validates :name,      :presence => true
  validates :ine_cpro,  :length => { :minimum => 2 }
  validates :region_id, :presence => true

  has_paper_trail
                       
  has_many :towns
  has_many :zipcodes
  has_many :companies
  has_many :offices
  has_many :workers
  has_many :shared_contacts
  def to_label
    "#{name} (#{region.name})"
  end

  def name_and_region
    self.name + " (" + self.region.name + ")"
  end
end
