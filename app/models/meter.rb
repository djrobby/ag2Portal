class Meter < ActiveRecord::Base
  belongs_to :meter_model
  belongs_to :caliber
  belongs_to :meter_owner
  belongs_to :organization
  attr_accessible :expiry_date, :first_installation_date, :last_withdrawal_date, :manufacturing_date, :manufacturing_year, :meter_code, :purchase_date,
                  :meter_model_id, :caliber_id, :meter_owner_id, :organization_id

  has_paper_trail

  validates :meter_model,         :presence => true
  validates :caliber,             :presence => true
  validates :meter_owner,         :presence => true
  validates :organization,        :presence => true
  validates :meter_code,          :presence => true,
                                  :length => { :minimum => 4, :maximum => 12 },
                                  :uniqueness => { :scope => :organization_id },
                                  :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid }
  validates :manufacturing_year,  :presence => true,
                                  :length => { :is => 4 },
                                  :numericality => { :only_integer => true, :greater_than => 0 }

  #has_many :meter_details
end
