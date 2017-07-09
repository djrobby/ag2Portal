class CompanyBankAccount < ActiveRecord::Base
  include ModelsModule

  belongs_to :company
  belongs_to :bank_account_class
  belongs_to :country
  belongs_to :bank
  belongs_to :bank_office
  attr_accessible :account_no, :bank_suffix, :ccc_dc, :ending_at, :holder_fiscal_id, :holder_name, :iban_dc, :starting_at,
                  :company_id, :bank_account_class_id, :country_id, :bank_id, :bank_office_id

  has_paper_trail

  validates :company,             :presence => true
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
                                  :uniqueness => { :scope => [:company_id, :bank_account_class_id, :country_id,
                                                              :iban_dc, :bank_id, :bank_office_id] }
  validates :holder_fiscal_id,    :presence => true,
                                  :length => { :minimum => 8 }
  validates :holder_name,         :presence => true
  validates :starting_at,         :presence => true
  validates :bank_suffix,         :presence => true,
                                  :length => { :is => 3 },
                                  :format => { with: /\A\d+\Z/, message: :suffix_invalid }

  # Scopes
  scope :active, -> { where("ending_at IS NULL OR ending_at > ?", Date.today) }
  scope :active_by_company, -> c { where("company_id = ? AND (ending_at IS NULL OR ending_at > ?)", c, Date.today) }

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

  def active
    ending_at.nil? || ending_at > Date.today
  end

  def full_name
    full_name = ""
    if !self.bank_account_class.blank?
      full_name += self.bank_account_class_id + ": "
    end
    full_name = e_format
  end

  def company_name
    !self.company.blank? ? self.company.name.strip : ''
  end

  def sanitized_company_name
    sanitize_string(company_name, true, true, true, false)
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
      _f += " " + self.account_no[0,4] + " " + self.account_no[4,4] + " " + self.account_no[8,4]
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

  # Generates ControlDigit for SEPA identifier
  # Returns SEPA Id
  def sepa_id
    country = self.country.code
    suffix = self.bank_suffix
    fiscal_id = self.holder_fiscal_id
  end
end
