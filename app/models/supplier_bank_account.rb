class SupplierBankAccount < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :bank_account_class
  belongs_to :country
  belongs_to :bank
  belongs_to :bank_office
  attr_accessible :account_no, :ccc_dc, :ending_at, :holder_fiscal_id, :holder_name, :iban_dc, :starting_at,
                  :supplier_id, :bank_account_class_id, :country_id, :bank_id, :bank_office_id, :iban

  has_paper_trail

  validates :supplier,            :presence => true
  validates :bank_account_class,  :presence => true
  validates :country,             :presence => true, :if => "!country.blank?"
  validates :iban_dc,             :presence => true,
                                  :length => { :is => 2 },
                                  :format => { with: /\A\d+\Z/, message: :dc_invalid },
                                  :if => "!iban_dc.blank?"
  validates :bank,                :presence => true, :if => "!bank.blank?"
  validates :bank_office,         :presence => true, :if => "!bank_office.blank?"
  # validates :ccc_dc,              :presence => true,
  #                                 :length => { :is => 2 },
  #                                 :format => { with: /\A\d+\Z/, message: :dc_invalid }
  validates :account_no,          :presence => true,
                                  :length => { :is => 12 },
                                  :format => { with: /\A\d+\Z/, message: :code_invalid },
                                  :uniqueness => { :scope => [:supplier_id, :bank_account_class_id, :country_id,
                                                              :iban_dc, :bank_id, :bank_office_id] },
                                  :if => "!account_no.blank?"
  validates :holder_fiscal_id,    :presence => true,
                                  :length => { :minimum => 8 }
  validates :holder_name,         :presence => true
  validates :starting_at,         :presence => true
  validates :iban,                :presence => true,
                                  :length => { :minimum => 4, :maximum => 34 },
                                  :format => { with: /\A[a-zA-Z\d]+\Z/, message: :iban_invalid },
                                  :if => "country.blank? && account_no.blank?"

  # Scopes
  scope :active, -> { where("ending_at IS NULL OR ending_at > ?", Date.today) }

  # Callbacks
  before_validation :fields_to_uppercase
  before_save :iban_save

  #
  # Methods
  #
  def fields_to_uppercase
    if !self.holder_fiscal_id.blank?
      self[:holder_fiscal_id].upcase!
    end
    if !self.iban.blank?
      self[:iban].upcase!
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

  def ccc_dc
    account_no[0..1]
  end

  def ccc_account_no
    account_no[2..-1]
  end

  def right_iban
    iban.blank? ? e_format : iban
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

  #
  # IBAN treatment
  #
  def iban_country
    !iban.blank? ? iban[0,2] : ''
  end
  def iban_dc_
    !iban.blank? ? iban[2,2] : ''
  end
  def iban_bank
    iban_country == 'ES' ? iban[4,4] : ''
  end
  def iban_office
    iban_country == 'ES' ? iban[8,4] : ''
  end
  def iban_ccc_dc
    iban_country == 'ES' ? iban[12,2] : ''
  end
  def iban_ccc
    iban_country == 'ES' ? iban[14,10] : ''
  end
  def iban_account_no
    iban_country == 'ES' ? iban[12,12] : ''
  end

  def iban_country_id
    Country.find_by_code(iban_country).id rescue nil
  end
  def iban_bank_id
    Bank.find_by_code(iban_bank).id rescue nil
  end
  def iban_office_id
    BankOffice.by_bank_and_code(iban_bank_id, iban_office).first.id rescue nil
  end

  def iban_format_with_spaces
    iban.gsub(/(.{4})(?=.)/, '\1 \2')
  end

  private

  def iban_save
    if iban.blank?
       # IBAN empty, must be generated if it's from Spain
       if (!country_id.blank? && !iban_dc.blank? && !bank.blank? && !bank_office.blank? && !account_no.blank?) &&
           country_code == 'ES'
          self.iban = e_format
       end
    else
      # IBAN filled, CCC data must be generated if it's from Spain
      if iban_country == 'ES'
        self.country_id = iban_country_id
        self.iban_dc = iban_dc_
        self.bank_id = iban_bank_id
        self.bank_office_id = iban_office_id
        self.account_no = iban_account_no
      end
    end
  end
end
