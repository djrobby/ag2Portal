class Client < ActiveRecord::Base
  include ModelsModule

  belongs_to :entity
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  belongs_to :organization
  belongs_to :ledger_account
  belongs_to :payment_method
  belongs_to :shared_contact
  attr_accessible :active, :building, :cellular, :client_code, :email, :fax, :fiscal_id, :floor, :floor_office,
                  :first_name, :last_name, :company, :phone, :remarks, :street_name, :street_number, :organization_id,
                  :entity_id, :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                  :created_by, :updated_by, :is_contact, :shared_contact_id, :ledger_account_id, :payment_method_id,
                  :old_code
  attr_accessible :client_bank_accounts_attributes, :client_ledger_accounts_attributes

  has_many :delivery_notes
  has_many :sale_offers
  has_many :client_bank_accounts, dependent: :destroy
  has_many :subscribers
  has_many :bills
  has_many :invoices, through: :bills
  has_many :client_payments
  has_many :invoice_debts
  has_many :invoice_current_debts
  has_many :cancelled_invoices
  has_many :active_invoices
  has_many :active_supply_invoices
  has_many :invoice_bills
  has_many :invoice_credits
  has_many :invoice_rebills
  has_many :water_supply_contracts
  has_many :water_connection_contracts
  has_many :supply_requests, :through => :water_supply_contracts, :source => :contracting_request
  has_many :connection_requests, :through => :water_connection_contracts, :source => :contracting_request
  has_many :client_ledger_accounts, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :client_bank_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :client_ledger_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :client_bank_accounts
  validates_associated :client_ledger_accounts

  validates :first_name,    :presence => true, :if => "company.blank?"
  validates :last_name,     :presence => true, :if => "company.blank?"
  validates :company,       :presence => true, :if => "last_name.blank?"
  validates :client_code,   :presence => true,
                            :length => { :is => 11 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :organization_id }
  validates :fiscal_id,     :presence => true,
                            :length => { :minimum => 8 },
                            :uniqueness => { :scope => :organization_id }
  validates :street_type,   :presence => true
  validates :zipcode,       :presence => true
  validates :town,          :presence => true
  validates :province,      :presence => true
  validates :region,        :presence => true
  validates :country,       :presence => true
  validates :entity,        :presence => true
  validates :organization,  :presence => true
  validates :payment_method,:presence => true

  # Scopes
  scope :by_code, -> { order("clients.client_code") }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_code }
  scope :actives, -> { where(active: true).by_code }
  scope :active_by_organization, -> o { where(active: true, organization_id: o).by_code }
  # generic where (eg. for Select2 from engines_controller)
  scope :g_where_all_h, -> h {
    select("id, active, fiscal_id, client_code, first_name, last_name, company,
            CASE WHEN (ISNULL(clients.company) OR clients.company = '') THEN CONCAT(clients.last_name, ', ', clients.first_name) ELSE clients.company END full_name")
    .by_code.having(h)
  }
  scope :g_where_all_oh, -> o, h {
    select("id, active, fiscal_id, client_code, first_name, last_name, company,
            CASE WHEN (ISNULL(clients.company) OR clients.company = '') THEN CONCAT(clients.last_name, ', ', clients.first_name) ELSE clients.company END full_name")
    .belongs_to_organization(o).having(h)
  }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records
  after_create :should_create_shared_contact, if: :is_contact?
  after_update :should_update_shared_contact, if: :is_contact?

  # Methods
  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.client_code.blank?
      self[:client_code].upcase!
    end
    true
  end

  def to_label
    if !self.last_name.blank? && !self.first_name.blank?
      "#{full_name_and_code}"
    else
      "#{full_code} #{company}"
    end
  end

  def to_name
    if !self.last_name.blank? && !self.first_name.blank?
      "#{full_name}"
    else
      "#{company}"
    end
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name[0,40]
  end

  def full_name_full
    full_name = ""
    if !company.blank?
      full_name = company
    else
      if !self.last_name.blank?
        full_name += self.last_name
      end
      if !self.first_name.blank?
        full_name += ", " + self.first_name
      end
    end
    full_name
  end

  def partial_name30
    full_name[0,30]
  end

  def full_name_and_code
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name = full_code + " " + full_name[0,40]
  end

  def full_name_or_company
    full_name_or_company = ""
    if !self.last_name.blank? || !self.first_name.blank?
      full_name_or_company = full_name
    else
      full_name_or_company = company[0,40] if !company.blank?
    end
    full_name_or_company
  end

  def full_name_or_company_and_code
    full_code + " " + full_name_or_company
  end

  def full_name_or_company_code_fiscal
    client_code + " " + full_name_or_company + " " + fiscal_id
  end

  def full_code
    # Client code (Organization id & sequential number) => OOOO-NNNNNNN
    client_code.blank? || client_code == "$ERR" ? "" : client_code[0..3] + '-' + client_code[4..10]
  end

  def diput
    client_code.blank? || client_code == "$ERR" ? "00000000" : client_code[2..3] + client_code[5..10]
  end

  def for_sepa_mandate_id
    self.id.blank? ? '00000000' : self.id.to_s.rjust(8,'0')
  end

  def entity_first_name
    self.entity.first_name
  end

  def entity_last_name
    self.entity.last_name
  end

  def entity_company
    self.entity.company
  end

  def address_1
    _ret = ""
    if !street_type.blank?
      _ret += street_type.street_type_code.titleize + ". "
    end
    if !street_name.blank?
      _ret += street_name + " "
    end
    if !street_number.blank?
      _ret += street_number
    end
    if !building.blank?
      _ret += ", " + building.titleize
    end
    if !floor.blank?
      _ret += ", " + floor_human
    end
    if !floor_office.blank?
      _ret += " " + floor_office
    end
    _ret
  end

  def address_2
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
      if !province.region.country.blank?
        _ret += "(" + province.region.country.name + ")"
      end
    end
    _ret
  end

  def address_3
    _ret = ""
    if !zipcode.blank?
      _ret += zipcode.zipcode + " "
    end
    if !town.blank?
      _ret += town.name + ", "
    end
    if !province.blank?
      _ret += province.name + " "
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  #
  # Calculated fields
  #
  def total_debt_unpaid
    invoice_debts.unpaid.sum(:debt)
  end

  def total_existing_debt
    invoice_debts.existing_debt.sum(:debt)
  end

  def total_debt
    invoices.sum(&:debt)
  end

  def current_debt
    Client.current_debt_calc(self.id)
    # invoices.sum(&:current_debt)
  end

  def current_debt_by_project
    Client.current_debt_calc_by_project(self.id)
  end

  def totals_date(from,to,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total) as total_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["total_total"]
  end

  def collected_date(from,to,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(collected) as collected_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["collected_total"]
  end

  def debt_date(from,to,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["debt"]
  end

  def totals_current_date(from,to,todebt,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total) as total_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.client_id = #{i} AND client_payments.payment_date <= '#{todebt.to_date}' AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["total_total"]
  end

  def collected_current_date(from,to,todebt,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(collected) as collected_total FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.client_id = #{i} AND client_payments.payment_date <= '#{todebt.to_date}' AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["collected_total"]
  end

  def debt_current_date(from,to,todebt,i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i} AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}')
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        INNER join invoices ON client_payments.invoice_id = invoices.id
        WHERE client_payments.client_id = #{i} AND client_payments.payment_date <= '#{todebt.to_date}' AND (invoices.invoice_date >= '#{from.to_date}' AND invoices.invoice_date <= '#{to.to_date}') AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["debt"]
  end

  def active_yes_no
    active ? I18n.t(:yes_on) : I18n.t(:no_off)
  end

  def ine_town_code
    town.ine_cmun + town.ine_dc
  end

  # Obtaining ledger account
  def ledger_account_id_by_company_id(company_id=nil)
    if company_id.nil?
      ledger_account_id
    else
      client_ledger_accounts.where(company_id: company_id).first.ledger_account_id rescue nil
    end
  end
  def ledger_account_code(company_id=nil)
    LedgerAccount.find(ledger_account_id_by_company_id(company_id)).code rescue nil
  end

  # Obtaining active bank account
  def active_bank_accounts?
    (client_bank_accounts_count > 0) && (!client_bank_accounts.where(ending_at: nil).blank?)
  end
  def active_bank_account
    client_bank_accounts.where(ending_at: nil).order(:starting_at).last
  end
  def active_bank_account_bank_code
    active_bank_account.bank.code rescue nil
  end
  def active_bank_account_office_code
    active_bank_account.bank_office.code rescue nil
  end
  def active_bank_account_ccc_dc
    active_bank_account.ccc_dc rescue nil
  end
  def active_bank_account_ccc_account_no
    active_bank_account.ccc_account_no rescue nil
  end
  def active_bank_account_iban_no
    active_bank_account.e_format rescue nil
  end

  # Obtaining entity type
  def entity_type
    entity.entity_type.id rescue 1
  end
  def entity_type_letter
    entity_type == 1 ? 'F' : 'J'
  end

  #
  # Records navigator
  #
  def to_first
    Client.order("client_code").first
  end

  def to_prev
    Client.where("client_code < ?", client_code).order("client_code").last
  end

  def to_next
    Client.where("client_code > ?", client_code).order("client_code").first
  end

  def to_last
    Client.order("client_code").last
  end

  # For CSV
  def european_fiscal_id
    country.code + fiscal_id
  end

  def name40
    !self.name.blank? ? sanitize_string(self.name[0,40].strip, true, true, true, false) : ''
  end
  def name35
    !self.name.blank? ? sanitize_string(self.name[0,35].strip, true, true, true, false) : ''
  end

  def sanitize_street_name
    !self.street_name.blank? ? sanitize_string(self.street_name.strip, true, true, true, false) : ''
  end
  def sanitize_address_1
    !self.address_1.blank? ? sanitize_string(self.address_1.strip, true, true, true, false) : ''
  end

  def sanitize_town_name
    !self.town.name.blank? ? sanitize_string(self.town.name.strip, true, true, true, false) : ''
  end

  def sanitize_province_name
    !self.province.name.blank? ? sanitize_string(self.province.name.strip, true, true, true, false) : ''
  end

  def sanitize_country_name
    !self.country.name.blank? ? sanitize_string(self.country.name.strip, true, true, true, false) : ''
  end

  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  # Client code
  def self.cl_next_code(organization)
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    last_code = Client.where("client_code LIKE ?", "#{organization}%").order(:client_code).maximum(:client_code)
    if last_code.nil?
      code = organization + '0000001'
    else
      last_code = last_code[4..10].to_i + 1
      code = organization + last_code.to_s.rjust(7, '0')
    end
    code
  end

  def self.current_debt_calc(i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i}
        UNION
        SELECT 0 as total, SUM(amount) as collected
        FROM client_payments
        WHERE client_payments.client_id = #{i} AND NOT ISNULL(client_payments.confirmation_date)
        ) a"
    ).first["debt"]
  end

  def self.current_debt_calc_by_project(i=nil)
    if i.nil?
      i = self.id
    end
    ActiveRecord::Base.connection.exec_query(
      "SELECT project_id, SUM(total)-SUM(collected) as debt FROM
        (
        SELECT SUM(receivables) as total, 0 as collected, bills.project_id
        FROM invoices
        INNER join bills ON invoices.bill_id = bills.id
        WHERE bills.client_id = #{i}
        group by bills.project_id
        UNION
        SELECT 0 as total, SUM(amount) as collected, bills.project_id
        FROM client_payments
        INNER JOIN bills on client_payments.bill_id=bills.id
        WHERE client_payments.client_id = #{i} AND NOT ISNULL(client_payments.confirmation_date)
        group by bills.project_id
        ) a"
    )
  end

  def self.to_client_csv(array)
    attributes = [array[0].sanitize("Id"),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.client_code')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.fiscal_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.name')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.address')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.phone')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.email'))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |client|
        csv << [ client.id,
                 client.client_code,
                 client.fiscal_id,
                 client.to_name,
                 client.address_1,
                 client.try(:phone),
                 client.try(:email)]
      end
    end
  end

  def self.to_client_debt_csv(array,from,to)
    attributes = [array[0].sanitize("Id"),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.client_code')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.fiscal_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.name')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.address')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.phone')),
                  array[0].sanitize(I18n.t('activerecord.attributes.client.email')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.total')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.charged_c')),
                  array[0].sanitize(I18n.t('activerecord.attributes.subscriber.debt'))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |client|
        total = client.totals_date(from,to).blank? ? 0 : client.totals_date(from,to)
        collected = client.collected_date(from,to).blank? ? 0 : client.collected_date(from,to)
        debt = client.debt_date(from,to).blank? ? 0 : client.debt_date(from,to)
        csv << [ client.id,
                 client.client_code,
                 client.fiscal_id,
                 client.to_name,
                 client.address_1,
                 client.try(:phone),
                 client.try(:email),
                 client.raw_number(total, 2),
                 client.raw_number(collected, 2),
                 client.raw_number(debt, 2)]
      end
    end
  end

  def self.to_csv(array, company_id=nil)
    column_names = [I18n.t('activerecord.csv_sage200.supplier.c001'),
                    I18n.t('activerecord.csv_sage200.supplier.c002'),
                    I18n.t('activerecord.csv_sage200.supplier.c003'),
                    I18n.t('activerecord.csv_sage200.supplier.c004'),
                    I18n.t('activerecord.csv_sage200.supplier.c005'),
                    I18n.t('activerecord.csv_sage200.supplier.c006'),
                    I18n.t('activerecord.csv_sage200.supplier.c007'),
                    I18n.t('activerecord.csv_sage200.supplier.c008'),
                    I18n.t('activerecord.csv_sage200.supplier.c009'),
                    I18n.t('activerecord.csv_sage200.supplier.c010'),
                    I18n.t('activerecord.csv_sage200.supplier.c011'),
                    I18n.t('activerecord.csv_sage200.supplier.c012'),
                    I18n.t('activerecord.csv_sage200.supplier.c013'),
                    I18n.t('activerecord.csv_sage200.supplier.c014'),
                    I18n.t('activerecord.csv_sage200.supplier.c015'),
                    I18n.t('activerecord.csv_sage200.supplier.c016'),
                    I18n.t('activerecord.csv_sage200.supplier.c017'),
                    I18n.t('activerecord.csv_sage200.supplier.c018'),
                    I18n.t('activerecord.csv_sage200.supplier.c019'),
                    I18n.t('activerecord.csv_sage200.supplier.c020'),
                    I18n.t('activerecord.csv_sage200.supplier.c021'),
                    I18n.t('activerecord.csv_sage200.supplier.c022'),
                    I18n.t('activerecord.csv_sage200.supplier.c023'),
                    I18n.t('activerecord.csv_sage200.supplier.c024'),
                    I18n.t('activerecord.csv_sage200.supplier.c025'),
                    I18n.t('activerecord.csv_sage200.supplier.c026'),
                    I18n.t('activerecord.csv_sage200.supplier.c027'),
                    I18n.t('activerecord.csv_sage200.supplier.c028'),
                    I18n.t('activerecord.csv_sage200.supplier.c029'),
                    I18n.t('activerecord.csv_sage200.supplier.c030'),
                    I18n.t('activerecord.csv_sage200.supplier.c031'),
                    I18n.t('activerecord.csv_sage200.supplier.c032'),
                    I18n.t('activerecord.csv_sage200.supplier.c033'),
                    I18n.t('activerecord.csv_sage200.supplier.c034'),
                    I18n.t('activerecord.csv_sage200.supplier.c035'),
                    I18n.t('activerecord.csv_sage200.supplier.c036'),
                    I18n.t('activerecord.csv_sage200.supplier.c037'),
                    I18n.t('activerecord.csv_sage200.supplier.c038'),
                    I18n.t('activerecord.csv_sage200.supplier.c039'),
                    I18n.t('activerecord.csv_sage200.supplier.c040'),
                    I18n.t('activerecord.csv_sage200.supplier.c041'),
                    I18n.t('activerecord.csv_sage200.supplier.c042'),
                    I18n.t('activerecord.csv_sage200.supplier.c043'),
                    I18n.t('activerecord.csv_sage200.supplier.c044'),
                    I18n.t('activerecord.csv_sage200.supplier.c045'),
                    I18n.t('activerecord.csv_sage200.supplier.c046'),
                    I18n.t('activerecord.csv_sage200.supplier.c047'),
                    I18n.t('activerecord.csv_sage200.supplier.c048'),
                    I18n.t('activerecord.csv_sage200.supplier.c049'),
                    I18n.t('activerecord.csv_sage200.supplier.c050'),
                    I18n.t('activerecord.csv_sage200.supplier.c051'),
                    I18n.t('activerecord.csv_sage200.supplier.c052'),
                    I18n.t('activerecord.csv_sage200.supplier.c053'),
                    I18n.t('activerecord.csv_sage200.supplier.c054'),
                    I18n.t('activerecord.csv_sage200.supplier.c055'),
                    I18n.t('activerecord.csv_sage200.supplier.c056'),
                    I18n.t('activerecord.csv_sage200.supplier.c057'),
                    I18n.t('activerecord.csv_sage200.supplier.c058'),
                    I18n.t('activerecord.csv_sage200.supplier.c059'),
                    I18n.t('activerecord.csv_sage200.supplier.c060'),
                    I18n.t('activerecord.csv_sage200.supplier.c061'),
                    I18n.t('activerecord.csv_sage200.supplier.c062'),
                    I18n.t('activerecord.csv_sage200.supplier.c063'),
                    I18n.t('activerecord.csv_sage200.supplier.c064'),
                    I18n.t('activerecord.csv_sage200.supplier.c065'),
                    I18n.t('activerecord.csv_sage200.supplier.c066'),
                    I18n.t('activerecord.csv_sage200.supplier.c067'),
                    I18n.t('activerecord.csv_sage200.supplier.c068'),
                    I18n.t('activerecord.csv_sage200.supplier.c069'),
                    I18n.t('activerecord.csv_sage200.supplier.c070')]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << column_names
      lac = nil
      array.each do |i|
        lac = i.ledger_account_code(company_id)
        if !lac.nil?
          csv << [i.ledger_account_company_code(company_id),  # 001
                  'P',                                    # 002
                  i.client_code,                          # 003
                  lac,                                    # 004
                  nil,  # 005
                  nil,  # 006
                  nil,  # 007
                  i.country.code,                         # 008
                  i.fiscal_id,                            # 009
                  i.european_fiscal_id,                   # 010
                  i.name40,                               # 011
                  nil,  # 012
                  nil,  # 013
                  nil,  # 014
                  nil,  # 015
                  nil,  # 016
                  i.name35,                               # 017
                  i.street_type.street_type_code,         # 018
                  i.sanitize_street_name,                 # 019
                  i.street_number,                        # 020
                  nil,  # 021
                  i.building,                             # 022
                  i.floor,                                # 023
                  i.floor_office,                         # 024
                  nil,  # 025
                  i.sanitize_address_1,                   # 026
                  i.zipcode.zipcode,                      # 027
                  i.ine_town_code,                        # 028
                  i.sanitize_town_name,                   # 029
                  i.province.ine_cpro,                    # 030
                  i.sanitize_province_name,               # 031
                  nil,  # 032
                  i.sanitize_country_name,                # 033
                  nil,  # 034
                  nil,  # 035
                  nil,  # 036
                  nil,  # 037
                  nil,  # 038
                  nil,  # 039
                  i.active_bank_account_bank_code,        # 040
                  i.active_bank_account_office_code,      # 041
                  i.active_bank_account_ccc_dc,           # 042
                  i.active_bank_account_ccc_account_no,   # 043
                  i.active_bank_account_iban_no,          # 044
                  nil,  # 045
                  nil,  # 046
                  nil,  # 047
                  nil,  # 048
                  nil,  # 049
                  nil,  # 050
                  nil,  # 051
                  nil,  # 052
                  nil,  # 053
                  nil,  # 054
                  nil,  # 055
                  nil,  # 056
                  nil,  # 057
                  nil,  # 058
                  i.province.territory_code,              # 059
                  nil,  # 060
                  '1',                                    # 061
                  nil,  # 062
                  nil,  # 063
                  nil,  # 064
                  i.entity_type_letter,                   # 065
                  nil,  # 066
                  nil,  # 067
                  nil,  # 068
                  nil,  # 069
                  nil]  # 070
        end # !lac.nil?
      end # array.each
    end # CSV.generate
  end

  searchable do
    text :client_code, :full_name, :company, :fiscal_id, :street_name, :phone, :cellular, :email
    string :address, :multiple => true do
      address_1 unless address_1.blank?
    end
    string :client_code, :multiple => true
    string :company
    string :full_name
    string :fiscal_id
    integer :organization_id
    string :sort_no do
      client_code
    end
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for delivery notes
    if delivery_notes.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_delivery_notes'))
      return false
    end
    # Check for sale offers
    if sale_offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_sale_offers'))
      return false
    end
    # Check for subscribers
    if subscribers.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_subscribers'))
      return false
    end
    # Check for invoices
    if bills.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_invoices'))
      return false
    end
    if invoices.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_invoices'))
      return false
    end
    # Check for charges
    if client_payments.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_client_charges'))
      return false
    end
    # Check for contracts
    if water_supply_contracts.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_water_supply_contracts'))
      return false
    end
    if water_connection_contracts.count > 0
      errors.add(:base, I18n.t('activerecord.models.client.check_for_water_connection_contracts'))
      return false
    end
  end

  #
  # Triggers to update linked models
  #
  # After create
  # Should create new Shared Contact (shared_contact_id not set)
  def should_create_shared_contact
    _entity = Entity.find(entity)
    # Maybe contact exists previously
    _contact = SharedContact.find_by_fiscal_id_organization_type(fiscal_id, organization_id, 3) rescue nil
    if _contact.nil?
      # Let's create a new contact
      _contact = create_shared_contact(_entity)
    else
      # Contact exists, updates it
      _contact = update_shared_contact(_contact, _entity)
    end
    # Update contact id
    self.update_column(:shared_contact_id, _contact.id) if !_contact.id.nil?
    true
  end

  # After update
  # Should update existing Shared Contact (shared_contact_id is set)
  def should_update_shared_contact
    _entity = Entity.find(entity)
    # Retrieve contact by its id
    _contact = SharedContact.find(shared_contact_id) rescue nil
    if _contact.nil?
      # Not found ??? Maybe is another contact... Let's check it out
      _contact = SharedContact.find_by_fiscal_id_organization_type(fiscal_id, organization_id, 3) rescue nil
      if _contact.nil?
        # No contact yet: Let's create a new one
        _contact = create_shared_contact(_entity)
      else
        # Contact exists but with a different id
        _contact = update_shared_contact(_contact, _entity)
      end
    else
      # Contact found, updates it
      _contact = update_shared_contact(_contact, _entity)
    end
    # Update contact id
    self.update_column(:shared_contact_id, _contact.id) if !_contact.id.nil?
    true
  end

  #
  # Helper methods for triggers
  #
  # Creates new Shared Contact
  def create_shared_contact(_entity)
    _contact = SharedContact.create(first_name: first_name, last_name: last_name, company: company,
                                    fiscal_id: fiscal_id, street_type_id: street_type_id, street_name: street_name,
                                    street_number: street_number, building: building, floor: floor,
                                    floor_office: floor_office, zipcode_id: zipcode_id, town_id: town_id,
                                    province_id: province_id, country_id: country_id, phone: phone,
                                    extension: _entity.extension, fax: fax, cellular: cellular,
                                    email: email, shared_contact_type_id: 3, region_id: region_id,
                                    organization_id: organization_id, created_by: created_by, updated_by: updated_by)
    return _contact
  end

  # Updates existing Shared Contact
  def update_shared_contact(_contact, _entity)
    _contact.attributes = { first_name: first_name, last_name: last_name, company: company,
                            fiscal_id: fiscal_id, street_type_id: street_type_id, street_name: street_name,
                            street_number: street_number, building: building, floor: floor,
                            floor_office: floor_office, zipcode_id: zipcode_id, town_id: town_id,
                            province_id: province_id, country_id: country_id, phone: phone,
                            extension: _entity.extension, fax: fax, cellular: cellular,
                            email: email, shared_contact_type_id: 3, region_id: region_id,
                            organization_id: organization_id, updated_by: updated_by }
    _contact.save
    return _contact
  end
end
