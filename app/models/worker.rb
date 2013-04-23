class Worker < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :office
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :collective_agreement
  belongs_to :contract_type
  belongs_to :degree_type
  belongs_to :professional_group
  belongs_to :worker_type
  belongs_to :department
  attr_accessible :building, :own_cellular, :email, :ending_at, :first_name,
                  :fiscal_id, :floor, :floor_office, :last_name, :own_phone,
                  :starting_at, :street_name, :street_number, :worker_code,
                  :user_id, :company_id, :office_id, :street_type_id,
                  :zipcode_id, :town_id, :province_id, :avatar,
                  :professional_group_id, :collective_agreement_id,
                  :degree_type_id, :contract_type_id, :worker_type_id,
                  :borned_on, :issue_starting_at, :affiliation_id,
                  :contribution_account_code, :position, :corp_phone,
                  :corp_cellular_long, :corp_cellular_short, :corp_extension,
                  :department_id, :nomina_id
  has_attached_file :avatar, :styles => { :medium => "96x96>", :small => "64x64>" }, :default_url => "/images/missing/:style/user.png"

  validates :first_name,                :presence => true,
                                        :length => { :minimum => 2 }
  validates :last_name,                 :presence => true,
                                        :length => { :minimum => 2 }
  validates :worker_code,               :presence => true,
                                        :length => { :minimum => 5 },
                                        :uniqueness => true
  validates :fiscal_id,                 :presence => true,
                                        :length => { :minimum => 9 },
                                        :uniqueness => true
  validates :user_id,                   :presence => true
  validates :company_id,                :presence => true
  validates :office_id,                 :presence => true
  validates :starting_at,               :presence => true
  validates :street_type_id,            :presence => true
  validates :zipcode_id,                :presence => true
  validates :town_id,                   :presence => true
  validates :province_id,               :presence => true
  validates :professional_group_id,     :presence => true
  validates :collective_agreement_id,   :presence => true
  validates :degree_type_id,            :presence => true
  validates :contract_type_id,          :presence => true
  validates :worker_type_id,            :presence => true
  validates :issue_starting_at,         :presence => true
  validates :affiliation_id,            :presence => true,
                                        :uniqueness => true
  validates :contribution_account_code, :presence => true

  before_validation :fields_to_uppercase

  has_many :time_records
  def fields_to_uppercase
    self[:fiscal_id].upcase!
    self[:worker_code].upcase!
  end

  def to_label
    "#{last_name}, #{first_name}"
  end

  def full_name
    self.last_name + ", " + self.first_name
  end

  searchable do
    text :worker_code, :first_name, :last_name, :fiscal_id, :affiliation_id, :contribution_account_code,
         :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email
    integer :company_id
    integer :office_id
  end
end
