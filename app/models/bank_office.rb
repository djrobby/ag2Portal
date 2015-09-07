class BankOffice < ActiveRecord::Base
  belongs_to :bank
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  attr_accessible :building, :cellular, :code, :email, :extension, :fax, :floor, :floor_office, :name, :phone,
                  :street_name, :street_number, :bank_id, :street_type_id, :zipcode_id, :town_id, :province_id,
                  :region_id, :country_id

  has_many :supplier_bank_accounts

  has_paper_trail

  validates :code,          :presence => true,
                            :length => { :is => 4 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :bank_id }
  validates :name,          :presence => true
  validates :swift,         :length => { :minimum => 8, :maximum => 11 }, :if => "!swift.blank?"
  validates :street_type,   :presence => true
  validates :zipcode,       :presence => true
  validates :town,          :presence => true
  validates :province,      :presence => true
  validates :region,        :presence => true
  validates :country,       :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for supplier bank accounts
    if supplier_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank_office.check_for_supplier_bank_accounts'))
      return false
    end
    # Check for client bank accounts
    if client_bank_accounts.count > 0
      errors.add(:base, I18n.t('activerecord.models.bank_office.check_for_client_bank_accounts'))
      return false
    end
  end
end
