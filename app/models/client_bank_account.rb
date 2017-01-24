class ClientBankAccount < ActiveRecord::Base
  belongs_to :client
  belongs_to :subscriber
  belongs_to :bank_account_class
  belongs_to :country
  belongs_to :bank
  belongs_to :bank_office
  attr_accessible :client_id, :subscriber_id, :bank_account_class_id, :account_no, :cb, :ccc_dc, :country_code, :cs,
                  :ending_at, :fiscal_id, :iban, :iban_dc, :name, :starting_at, :country_id, :bank_id, :bank_office_id, :holder_fiscal_id, :holder_name

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
                                  :length => { :is => 10 },
                                  :format => { with: /\A\d+\Z/, message: :code_invalid },
                                  :uniqueness => { :scope => [:bank_account_class_id, :country_id,
                                                              :iban_dc, :bank_id, :bank_office_id, :ccc_dc] }
  validates :holder_fiscal_id,    :presence => true,
                                  :length => { :minimum => 8 }
  validates :holder_name,         :presence => true
  validates :starting_at,         :presence => true

  # Scopes
  scope :active, -> { where("ending_at IS NULL OR ending_at > ?", Date.today) }

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
    if !self.ccc_dc.blank?
      _f += self.ccc_dc.strip
    end
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
    if !self.ccc_dc.blank?
      _f += " " + self.ccc_dc.strip
    end
    if !self.account_no.blank?
      _f += self.account_no[0,2] + " " + self.account_no[2,4] + " " + self.account_no[6,4]
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
    if !self.ccc_dc.blank?
      _f += " " + self.ccc_dc.strip
    end
    if !self.account_no.blank?
      _f += self.account_no[0,2] + " " + self.account_no[2,4] + " " + self.account_no[6,4]
    end
    if !_f.blank?
      _f = "IBAN " + _f
    end
    _f
  end

  def p_format_view
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
    if !self.ccc_dc.blank?
      _f += " " + self.ccc_dc.strip
    end
    if !self.account_no.blank?
      _f += self.account_no[0,2] + " " + self.account_no[2,2] + " " +  self.account_no[4,2].tr(account_no, "*") + " " +self.account_no[6,4].tr(account_no, "*")
    end
    if !_f.blank?
      _f = "IBAN " + _f
    end
    _f
  end
end
