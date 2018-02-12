class ClientBankAccount < ActiveRecord::Base
  belongs_to :client, :counter_cache => true
  belongs_to :subscriber, :counter_cache => true
  belongs_to :bank_account_class
  belongs_to :country
  belongs_to :bank
  belongs_to :bank_office
  attr_accessible :client_id, :subscriber_id, :bank_account_class_id, :account_no, :cb, :ccc_dc, :country_code, :cs,
                  :ending_at, :fiscal_id, :iban, :iban_dc, :name, :starting_at, :country_id, :bank_id, :bank_office_id,
                  :holder_fiscal_id, :holder_name, :created_by, :updated_by

  alias_attribute :cb, :bank_id
  alias_attribute :cs, :bank_office_id
  alias_attribute :fiscal_id, :holder_fiscal_id
  alias_attribute :name, :holder_name
  alias_attribute :country_code, :country_id

  has_paper_trail

  validates :client,              :presence => true
  validates :bank_account_class,  :presence => true
  validates :country,             :presence => true
  validates :iban_dc,             :presence => true,
                                  :length => { :is => 2 },
                                  :format => { with: /\A\d+\Z/, message: :dc_invalid }
  validates :bank,                :presence => true
  validates :bank_office,         :presence => true
  # validates :ccc_dc,              :presence => true,
  #                                 :length => { :is => 2 },
  #                                 :format => { with: /\A\d+\Z/, message: :dc_invalid }
  validates :account_no,          :presence => true,
                                  :length => { :is => 12 },
                                  :format => { with: /\A\d+\Z/, message: :code_invalid },
                                  :uniqueness => { :scope => [:bank_account_class_id, :country_id,
                                                              :iban_dc, :bank_id, :bank_office_id, :ccc_dc] }
  validates :holder_fiscal_id,    :presence => true,
                                  :length => { :minimum => 8 }
  validates :holder_name,         :presence => true
  validates :starting_at,         :presence => true

  # Scopes
  scope :by_ending_at, -> { order(:ending_at) }
  scope :by_ending_at_desc, -> { order('ending_at DESC') }
  #
  scope :active, -> { where("ending_at IS NULL OR ending_at > ?", Date.today) }
  scope :by_client_or_subscriber, -> c, s { where('client_id = ? OR subscriber_id = ?', c, s).by_ending_at }
  scope :by_client, -> c { where('client_id = ?', c).by_ending_at }
  scope :by_client_full, -> c {
    joins(:bank_account_class, :country, :bank, :bank_office)
    .joins('LEFT JOIN subscribers ON client_bank_accounts.subscriber_id = subscribers.id')
    .where('client_bank_accounts.client_id = ?', c)
    .select("bank_account_classes.name bank_account_class_name,
             CONCAT(TRIM(countries.code),TRIM(client_bank_accounts.iban_dc),' ',TRIM(banks.code),' ',TRIM(bank_offices.code),' ',SUBSTR(client_bank_accounts.account_no,1,4),' ',SUBSTR(client_bank_accounts.account_no,5,4),' ',SUBSTR(client_bank_accounts.account_no,9,4)) iban_with_spaces,
             CASE ISNULL(client_bank_accounts.subscriber_id) WHEN TRUE THEN '' ELSE CONCAT(SUBSTR(subscribers.subscriber_code,1,4),'-',SUBSTR(subscribers.subscriber_code,5,7)) END subscriber_full_code,
             client_bank_accounts.holder_name holder_name, client_bank_accounts.holder_fiscal_id holder_fiscal_id,
             client_bank_accounts.starting_at, client_bank_accounts.ending_at, (ending_at IS NULL OR ending_at > CURDATE()) is_active")
    .by_ending_at
  }
  scope :by_subscriber, -> s { where('subscriber_id = ?', s).by_ending_at }
  scope :by_subscriber_full, -> s {
    joins(:bank_account_class, :country, :bank, :bank_office)
    .where('client_bank_accounts.subscriber_id = ?', s)
    .select("bank_account_classes.name bank_account_class_name,
             CONCAT(TRIM(countries.code),TRIM(client_bank_accounts.iban_dc),' ',TRIM(banks.code),' ',TRIM(bank_offices.code),' ',SUBSTR(client_bank_accounts.account_no,1,4),' ',SUBSTR(client_bank_accounts.account_no,5,4),' ',SUBSTR(client_bank_accounts.account_no,9,4)) iban_with_spaces,
             client_bank_accounts.holder_name holder_name, client_bank_accounts.holder_fiscal_id holder_fiscal_id,
             client_bank_accounts.starting_at, client_bank_accounts.ending_at, (ending_at IS NULL OR ending_at > CURDATE()) is_active")
    .by_ending_at
  }
  scope :active_by_client_or_subscriber, -> c, s { active.where('client_id = ? OR subscriber_id = ?', c, s).by_ending_at }
  scope :active_by_client, -> c { active.where('client_id = ?', c).by_ending_at }
  scope :active_by_subscriber, -> s { active.where('subscriber_id = ?', s).by_ending_at }

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.holder_fiscal_id.blank?
      self[:holder_fiscal_id].upcase!
    end
    true
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.bank_account_class.blank?
      full_name += self.bank_account_class_id + ": "
    end
    full_name = e_format
  end

  # Reference for SEPA mandate
  def refere_based_on_diput
    yy = self.starting_at.year
    mm = self.starting_at.month
    if yy >= 2000
      yy = yy - 2000
    end
    if yy > 1900
      yy = yy - 1900
    end
    diput = !self.subscriber.blank? ? self.subscriber.diput : self.client.diput
    (yy * 10000000000) + (mm * 100000000) + diput.to_i
  end
  def refere
    yy = self.starting_at.year
    mm = self.starting_at.month
    if yy >= 2000
      yy = yy - 2000
    end
    if yy > 1900
      yy = yy - 1900
    end
    refere = !self.subscriber.blank? ? self.subscriber.for_sepa_mandate_id : self.client.for_sepa_mandate_id
    (yy * 10000000000) + (mm * 100000000) + refere.to_i
  end

  def e_format
    _f = ""
    if !self.country.blank?
      _f += self.country.code.strip
    end
    if !self.iban_dc.blank?
      _f += self.iban_dc.strip
    end
    if !self.bank.blank?
      _f += self.bank.code.strip
    end
    if !self.bank_office.blank?
      _f += self.bank_office.code.strip
    end
    # if !self.ccc_dc.blank?
    #   _f += self.ccc_dc.strip
    # end
    if !self.account_no.blank?
      _f += self.account_no.strip
    end
    _f
  end

  def e_format_with_spaces
    _f = ""
    if !self.country.blank?
      _f += self.country.code.strip
    end
    if !self.iban_dc.blank?
      _f += self.iban_dc.strip
    end
    if !self.bank.blank?
      _f += " " + self.bank.code.strip
    end
    if !self.bank_office.blank?
      _f += " " + self.bank_office.code.strip
    end
    # if !self.ccc_dc.blank?
    #   _f += " " + self.ccc_dc.strip
    # end
    if !self.account_no.blank?
      _f +=  " " + self.account_no[0,4] + " " + self.account_no[4,4] + " " + self.account_no[8,4]
    end
    _f
  end

  def p_format
    _f = ""
    if !self.country.blank?
      _f += self.country.code.strip
    end
    if !self.iban_dc.blank?
      _f += self.iban_dc.strip
    end
    if !self.bank.blank?
      _f += " " + self.bank.code.strip
    end
    if !self.bank_office.blank?
      _f += " " + self.bank_office.code.strip
    end
    # if !self.ccc_dc.blank?
    #   _f += " " + self.ccc_dc.strip
    # end
    if !self.account_no.blank?
      _f += " " + self.account_no[0,4] + " " + self.account_no[4,4] + " " + self.account_no[8,4]
    end
    if !_f.blank?
      _f = "IBAN " + _f
    end
    _f
  end

  def p_format_hidden_account
    _f = ""
    if !self.country.blank?
      _f += self.country.code.strip
    end
    if !self.iban_dc.blank?
      _f += self.iban_dc.strip
    end
    if !self.bank.blank?
      _f += " " + self.bank.code.strip
    end
    if !self.bank_office.blank?
      _f += " " + self.bank_office.code.strip
    end
    # if !self.ccc_dc.blank?
    #   _f += " " + self.ccc_dc.strip
    # end
    if !self.account_no.blank?
      _f +=  " " + self.account_no[0,4] + " " + self.account_no[4,2] + self.account_no[6,2].tr(account_no, "*") + " " + self.account_no[8,4].tr(account_no, "*")
    end
    if !_f.blank?
      _f = "IBAN " + _f
    end
    _f
  end

  def swift
    !self.bank.blank? ? self.bank.swift_to_label : ''
  end
end
