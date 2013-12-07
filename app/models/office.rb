class Office < ActiveRecord::Base
  belongs_to :company
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type

  attr_accessible :name, :company_id, :office_code,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :created_by, :updated_by, :nomina_id

  has_paper_trail

  validates :name,            :presence => true
  validates :company_id,      :presence => true
  validates :office_code,     :presence => true,
                              :length => { :minimum => 5 },
                              :uniqueness => true
  validates :street_type_id,  :presence => true
  validates :zipcode_id,      :presence => true
  validates :town_id,         :presence => true
  validates :province_id,     :presence => true

  has_many :workers
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :tickets
  has_many :projects
  def to_label
    "#{name} (#{company.name})"
  end
end
