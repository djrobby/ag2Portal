class ContractingRequest < ActiveRecord::Base
  include ModelsModule

  # RELATIONS
  belongs_to :client_country, :class_name => 'Country', :foreign_key => 'client_country_id'
  belongs_to :client_province, :class_name => 'Province', :foreign_key => 'client_province_id'
  belongs_to :client_region, :class_name => 'Region', :foreign_key => 'client_region_id'
  belongs_to :client_street_directory, :class_name => 'StreetDirectory', :foreign_key => 'client_street_directory_id'
  belongs_to :client_street_type, :class_name => 'StreetType', :foreign_key => 'client_street_type_id'
  belongs_to :client_town, :class_name => 'Town', :foreign_key => 'client_town_id'
  belongs_to :client_zipcode, :class_name => 'Zipcode', :foreign_key => 'client_zipcode_id'
  belongs_to :entity_country, :class_name => 'Country', :foreign_key => 'entity_country_id'
  belongs_to :entity_province, :class_name => 'Province', :foreign_key => 'entity_province_id'
  belongs_to :entity_region, :class_name => 'Region', :foreign_key => 'entity_region_id'
  belongs_to :entity_street_directory, :class_name => 'StreetDirectory', :foreign_key => 'entity_street_directory_id'
  belongs_to :entity_street_type, :class_name => 'StreetType', :foreign_key => 'entity_street_type_id'
  belongs_to :entity_town, :class_name => 'Town', :foreign_key => 'entity_town_id'
  belongs_to :entity_zipcode, :class_name => 'Zipcode', :foreign_key => 'entity_zipcode_id'
  belongs_to :subscriber_country, :class_name => 'Country', :foreign_key => 'subscriber_country_id'
  belongs_to :subscriber_province, :class_name => 'Province', :foreign_key => 'subscriber_province_id'
  belongs_to :subscriber_region, :class_name => 'Region', :foreign_key => 'subscriber_region_id'
  belongs_to :subscriber_street_directory, :class_name => 'StreetDirectory', :foreign_key => 'subscriber_street_directory_id'
  belongs_to :subscriber_street_type, :class_name => 'StreetType', :foreign_key => 'subscriber_street_type_id'
  belongs_to :subscriber_town, :class_name => 'Town', :foreign_key => 'subscriber_town_id'
  belongs_to :subscriber_zipcode, :class_name => 'Zipcode', :foreign_key => 'subscriber_zipcode_id'
  belongs_to :subscriber_center, :class_name => 'Center', :foreign_key => 'subscriber_center_id'
  belongs_to :entity
  belongs_to :old_subscriber, :class_name => 'Subscriber', :foreign_key => "subscriber_id"
  belongs_to :project
  belongs_to :contracting_request_status
  belongs_to :contracting_request_type
  belongs_to :work_order
  belongs_to :service_point
  belongs_to :country
  belongs_to :bank
  belongs_to :bank_office

  delegate :subscriber, to: :water_supply_contract, allow_nil: true

  attr_accessible :client_building, :client_cellular, :client_country_id, :client_email,
                  :client_fax, :client_floor, :client_floor_office, :client_phone,
                  :client_province_id, :client_region_id, :client_street_directory_id,
                  :client_street_name, :client_street_number, :client_street_type_id,
                  :client_town_id, :client_zipcode_id, :entity_fiscal_id, :entity_building, :entity_country_id,
                  :entity_floor, :entity_floor_office, :entity_id, :entity_province_id,
                  :entity_region_id, :entity_street_directory_id, :entity_street_name,
                  :entity_street_number, :entity_street_type_id, :entity_town_id,
                  :entity_zipcode_id, :project_id, :r_first_name, :r_fiscal_id, :r_last_name,
                  :request_date, :request_no, :contracting_request_status_id, :contracting_request_type_id,
                  :subscriber_center_id, :subscriber_building, :subscriber_country_id,
                  :subscriber_floor, :subscriber_floor_office, :subscriber_province_id,
                  :subscriber_region_id, :subscriber_street_directory_id, :subscriber_street_name,
                  :subscriber_street_number, :subscriber_street_type_id, :subscriber_town_id,
                  :subscriber_zipcode_id, :iban, :country_id, :iban_dc, :bank_id, :bank_office_id, :ccc_dc,
                  :account_no, :work_order_id, :subscriber_id, :service_point_id, :service_point, :iban,
                  :created_by

  attr_accessible :contracting_request_documents_attributes

  has_many :contracting_request_documents
  accepts_nested_attributes_for :contracting_request_documents
  has_one :water_supply_contract
  has_one :client, through: :entity
  has_one :water_connection_contract

  has_paper_trail

  # Nested attributes
  accepts_nested_attributes_for :contracting_request_documents, :reject_if => :all_blank, :allow_destroy => true

  # VALIDATORS
  validates_associated :contracting_request_documents
  validates :request_no,                  :presence => true,
                                          :length => { :is => 22 },
                                          :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid }
                                          # ,:uniqueness => { :scope => :project_id }
  validates :project,                     :presence => true
  validates :request_date,                :presence => true
  validates :contracting_request_type,    :presence => true
  validates :contracting_request_status,  :presence => true
  validates :entity,                      :presence => true
  validates :entity_fiscal_id,            :presence => true
  validates :entity_country,              :presence => true
  validates :entity_province,             :presence => true
  validates :entity_region,               :presence => true
  validates :entity_street_name,          :presence => true
  validates :entity_street_number,        :presence => true
  validates :entity_street_type,          :presence => true
  validates :entity_town,                 :presence => true
  validates :entity_zipcode,              :presence => true
  validates :client_country,              :presence => true
  # validates :client_phone,                :presence => true
  validates :client_province,             :presence => true
  validates :client_region,               :presence => true
  validates :client_street_name,          :presence => true
  validates :client_street_number,        :presence => true
  validates :client_street_type,          :presence => true
  validates :client_town,                 :presence => true
  validates :client_zipcode,              :presence => true
  validates :subscriber_center,           :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_country,          :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_province,         :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_region,           :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_street_directory, :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_street_number,    :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_street_type,      :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_town,             :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :subscriber_zipcode,          :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  validates :service_point_id,            :presence => true, if: 'contracting_request_type_id!=ContractingRequestType::CONNECTION'
  # validates :subscriber_id,             presence: true, if: "contracting_request_type_id==2"
  validates :iban,                        :length => { :minimum => 4, :maximum => 34 },
                                          :format => { with: /\A[a-zA-Z\d]+\Z/, message: :iban_invalid },
                                          :if => "!iban.blank?"

  validate :check_document_required?

  # Scopes
  scope :by_no, -> { order(:request_no) }
  #
  scope :is_supply, -> { where("contracting_request_type_id <> ?", 3).by_no }
  scope :is_connection, -> { where(contracting_request_type_id: 3).by_no }
  scope :belongs_to_organization, -> org { joins(:project).where("projects.organization_id = ?", org).by_no }
  scope :belongs_to_project, -> p { where(project_id: p).by_no }
  scope :is_supply_belongs_to_organization, -> org { joins(:project).where("projects.organization_id = ? AND contracting_request_type_id <> ?", org, 3).by_no }
  scope :is_connection_belongs_to_organization, -> org { joins(:project).where("projects.organization_id = ? AND contracting_request_type_id = ?", org, 3).by_no }
  scope :is_supply_belongs_to_project, -> p { where(project_id: p).where("contracting_request_type_id <> ?", 3).by_no }
  scope :is_connection_belongs_to_project, -> p { where(project_id: p, contracting_request_type_id: 3).by_no }
  # generic where (eg. for Select2 from engines_controller)
  scope :g_where, -> w {
    joins(:project)
    .joins("LEFT JOIN (water_supply_contracts INNER JOIN clients AS supply_clients ON supply_clients.id=water_supply_contracts.client_id) ON water_supply_contracts.contracting_request_id=contracting_requests.id")
    .joins("LEFT JOIN (water_connection_contracts INNER JOIN clients AS connection_clients ON connection_clients.id=water_connection_contracts.client_id) ON water_connection_contracts.contracting_request_id=contracting_requests.id")
    .where(w)
    .by_no
  }
  scope :with_these_ids, -> ids {
    includes(:project, :contracting_request_type, :client, :entity, :contracting_request_status, [water_supply_contract: :bill])
    .where(id: ids)
  }

  # Callbacks
  after_create :to_client #create/assign client after create contracting_request
  before_save :assign_right_no

  # Searchable attributes
  searchable do
    text :request_no
    text :client_info
    text :client_code_name_fiscal do
      water_supply_contract.client.full_name_or_company_code_fiscal unless (water_supply_contract.blank? || water_supply_contract.client.blank?)
    end
    text :old_subscriber_code_name_address_fiscal do
      old_subscriber.code_full_name_or_company_address_fiscal unless old_subscriber.blank?
    end
    text :service_point_full_address do
      service_point.full_address unless service_point.blank?
    end
    integer :id
    string :request_no
    string :contracting_request_type_id
    string :project_id
    string :contracting_request_status_id
    integer :subscriber_id
    integer :service_point_id
    date :request_date
    string :sort_no do
      request_no
    end
  end

  # Preformatted information
  def client_info
    "#{client.to_name} #{client.fiscal_id}" if client
  end

  def entity_info
    r_first_name.blank? ? "" : r_first_name + " " + r_last_name
  end

  def subscriber_info_street
    subscriber_street_directory.blank? ? a1 = subscriber_street_type.street_type_code + " " + subscriber_street_name + ", " + subscriber_street_number : a = subscriber_street_directory.to_label + ", " + subscriber_street_number
    b = subscriber_building.blank? ? "" : ", " + subscriber_building
    c = subscriber_floor.blank? ? "" : ", " + subscriber_floor
    d = subscriber_floor_office.blank? ? "" : ", " + subscriber_floor_office
    subscriber_street_directory.blank? ? a1 + b + c + d : a + b + c + d
  end

  def subscriber_address_2
    _ret = ""
    if !subscriber_zipcode.blank?
      _ret += subscriber_zipcode.zipcode + " "
    end
    if !subscriber_street_directory.blank?
      _ret += subscriber_street_directory.town.name + ", "
      _ret += subscriber_street_directory.town.province.name + " "
      if !subscriber_street_directory.town.province.region.country.blank?
        _ret += "(" + subscriber_street_directory.town.province.region.country.name + ")"
      end
    end
    _ret
  end

  def document_types
    _codes = ""
    _ii = contracting_request_documents.group(:contracting_request_document_type_id)
    _ii.each do |r|
      if _codes == ""
        _codes += r.contracting_request_document_type.name
      else
        _codes += (" - " + r.contracting_request_document_type.name)
      end
    end
    _codes
  end

  def contracting_client
    _f = nil
    if !water_supply_contract.nil?
      _f = water_supply_contract.client.nil? ? nil : water_supply_contract.client
    elsif !water_connection_contract.nil?
      _f = !water_connection_contract.client.nil? ? nil : !water_connection_contract.client
    end
    _f
  end

  def full_no_and_client_name
    _f = full_no
    _f += " " + (contracting_client.nil? ? "N/A" : contracting_client.full_name_or_company)
  end

  def full_no_date_client
    full_name = full_no
    if !self.request_date.blank?
      full_name += " " + formatted_date(self.request_date)
    end
    full_name += " " + (contracting_client.nil? ? "N/A" : contracting_client.full_name_or_company)
  end

  def to_label
    full_no_date_client
  end

  def full_name
    full_no
  end

  def full_no
    # Request no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    request_no.blank? ? "" : request_no[0..11] + '-' + request_no[12..15] + '-' + request_no[16..21]
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

  # Records navigator
  def to_first
    ContractingRequest.order("request_no").first
  end

  def to_prev
    ContractingRequest.where("request_no < ?", request_no).order("request_no").last
  end

  def to_next
    ContractingRequest.where("request_no > ?", request_no).order("request_no").first
  end

  def to_last
    ContractingRequest.order("request_no").last
  end

  # check bank account info
  def data_account?
    !country_id.blank? && !iban_dc.blank? && !bank_id.blank? && !bank_office_id.blank? && !account_no.blank?
  end

  def data_iban?
    !iban.blank?
  end

  # Assign right request no (if current one is empty or already exists)
  def assign_right_no
    no = self.request_no
    id = self.id rescue nil
    if ((no.blank? || ContractingRequest.exists?(request_no: no)) && id.nil?)
      no = cr_next_no(self.project_id)
      if no == '$err'
        no = self.request_no
      end
    end
    self.request_no = no
  end

  def to_client
    client = entity.client || Client.create(
      active: true,
      building: client_building,
      cellular: client_cellular,
      client_code: Client.cl_next_code(project.organization.id),
      email: client_email,
      fax: client_fax,
      fiscal_id: entity.fiscal_id,
      floor: client_floor,
      floor_office: client_floor_office,
      first_name: entity.first_name,
      last_name: entity.last_name,
      company: entity.company,
      phone: client_phone,
      street_name: client_street_name,
      street_number: client_street_number,
      organization_id: project.organization.id,
      entity_id: entity_id,
      street_type_id: client_street_type_id,
      zipcode_id: client_zipcode_id,
      town_id: client_town_id,
      province_id: client_province_id,
      region_id: client_region_id,
      country_id: client_country_id,
      created_by: created_by,
      payment_method_id: iban.blank? ? 1 : 6
    )
    if self.contracting_request_type_id != ContractingRequestType::CANCELLATION
      client.client_bank_accounts.where(ending_at: nil, subscriber_id: subscriber_id).update_all(ending_at: request_date, updated_by: self.created_by)
    end
    ClientBankAccount.create(client_id: client.id,
                              bank_account_class_id: BankAccountClass::SERVICIO,
                              starting_at: request_date,
                              # country_id: country_id,
                              # iban_dc: iban_dc,
                              # bank_id: bank_id,
                              # bank_office_id: bank_office_id,
                              # ccc_dc: ccc_dc,
                              # account_no: account_no,
                              iban: iban,
                              created_by: created_by,
                              holder_fiscal_id: client.fiscal_id,
                              holder_name: client.to_name) if data_iban?
  end

  def to_subscriber
    _subscriber = subscriber || Subscriber.create(
      active: true,
      # billing_frequency_id: ,
      first_name: entity.first_name,
      last_name: entity.last_name,
      company: entity.company,
      building: subscriber_building,
      cadastral_reference: (water_supply_contract.cadastral_reference if water_supply_contract),
      # cellular: ,
      center_id: subscriber_center_id,
      client_id: client.id,
      # contract: ,
      country_id: subscriber_country_id,
      # email: ,
      # ending_at: ,
      endowments: (water_supply_contract.endowments if water_supply_contract),
      # fax: ,
      fiscal_id: entity.fiscal_id,
      floor: subscriber_floor,
      floor_office: subscriber_floor_office,
      pub_record: (water_supply_contract.pub_record if water_supply_contract),
      gis_id: (water_supply_contract.gis_id if water_supply_contract),
      inhabitants: (water_supply_contract.inhabitants if water_supply_contract),
      inhabitants_ending_at: (water_supply_contract.inhabitants_ending_at if water_supply_contract),
      meter_id: (water_supply_contract.meter_id if water_supply_contract),
      # name: ,
      # office_id: ,
      # phone: ,
      province_id: subscriber_province_id,
      # reading_route_id: ,
      # reading_sequence: ,
      # reading_variant: ,
      region_id: subscriber_region_id,
      # remarks: ,
      # starting_at: ,
      street_directory_id: subscriber_street_directory_id,
      street_name: subscriber_street_name,
      street_number: subscriber_street_number,
      street_type_id: subscriber_street_type_id,
      subscriber_code: sub_next_no(project.office_id),
      # tariff_id: (water_supply_contract.tariff_id if water_supply_contract),
      town_id: subscriber_town_id,
      zipcode_id: subscriber_zipcode_id,
      tariff_scheme_id: water_supply_contract.tariff_scheme_id,
      cellular: client_cellular,
      email: client_email,
      phone: client_phone,
      fax: client_fax,
      postal_first_name: client.first_name,
      postal_last_name: client.last_name,
      postal_company: client.company,
      postal_street_directory_id: client_street_directory_id,
      postal_street_type_id: client_street_type_id,
      postal_street_name: client_street_name,
      postal_street_number: client_street_number,
      postal_building: client_building,
      postal_floor: client_floor,
      postal_floor_office: client_floor_office,
      postal_zipcode_id: client_zipcode_id,
      postal_town_id: client_town_id,
      postal_province_id: client_province_id,
      postal_region_id: client_region_id,
      postal_country_id: client_country_id,
      service_point_id: service_point_id
    )
    water_supply_contract.update_attributes(subscriber_id: _subscriber.id) if water_supply_contract
    # self.update_attributes(subscriber_id: subscriber.id)
  end

  def to_cancellation
    water_supply_contract = WaterSupplyContract.new(
                              contract_no: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_no : nil,
                              contracting_request_id: id,
                              client_id: client.id,
                              reading_route_id: old_subscriber.reading_route_id,
                              meter_id: old_subscriber.meter_id,
                              tariff_scheme_id: old_subscriber.tariff_scheme_id,
                              contract_date: Date.today,
                              reading_sequence: old_subscriber.reading_sequence,
                              cadastral_reference: old_subscriber.cadastral_reference,
                              pub_record: old_subscriber.pub_record,
                              gis_id: old_subscriber.gis_id,
                              min_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.min_pressure : nil,
                              max_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.max_pressure : nil,
                              contract_term: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_term : nil,
                              remarks: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.remarks : nil,
                              caliber_id: old_subscriber.meter.caliber_id,
                              endowments: old_subscriber.endowments,
                              inhabitants: old_subscriber.inhabitants,
                              inhabitants_ending_at: old_subscriber.inhabitants_ending_at,
                              use_id:old_subscriber.use_id,
                              created_by: created_by #,
                              #tariff_type_id: old_subscriber.subscriber_tariffs.where(ending_at: nil).last.tariff.tariff_type_id
                            )
    water_supply_contract.save

    old_subscriber.subscriber_tariffs.where(ending_at: nil).each do |st|
        _subscriber_tariffs = st.tariff
        water_supply_contract.tariffs << _subscriber_tariffs
    end

    if !client.client_bank_accounts.where(ending_at: nil).blank?
      self.update_attributes(
        # country_id: client.client_bank_accounts.where(ending_at: nil).last.country_id,
        # iban_dc: client.client_bank_accounts.where(ending_at: nil).last.iban_dc,
        # bank_id: client.client_bank_accounts.where(ending_at: nil).last.bank_id,
        # bank_office_id: client.client_bank_accounts.where(ending_at: nil).last.bank_office_id,
        # ccc_dc: client.client_bank_accounts.where(ending_at: nil).last.ccc_dc,
        created_by: created_by,
        iban: client.client_bank_accounts.where(ending_at: nil).last.iban
        # account_no: client.client_bank_accounts.where(ending_at: nil).last.account_no
      )
      self.save
    end
  end

  #change_owner
  def to_subrogation
    water_supply_contract = WaterSupplyContract.create(
                              contract_no: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_no : nil,
                              contracting_request_id: id,
                              client_id: client.id,
                              subscriber_id: old_subscriber.id,
                              reading_route_id: old_subscriber.reading_route_id,
                              work_order_id: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.work_order_id : nil,
                              tariff_scheme_id: old_subscriber.tariff_scheme_id,
                              bill_id: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.bill_id : nil,
                              meter_id: old_subscriber.meter_id,
                              contract_date: request_date,
                              reading_sequence: old_subscriber.reading_sequence,
                              cadastral_reference: old_subscriber.cadastral_reference,
                              pub_record: old_subscriber.pub_record,
                              gis_id: old_subscriber.gis_id,
                              min_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.min_pressure : nil,
                              max_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.max_pressure : nil,
                              contract_term: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_term : nil,
                              remarks: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.remarks : nil,
                              caliber_id: old_subscriber.meter.caliber_id,
                              #tariff_type_id: old_subscriber.subscriber_tariffs.where(ending_at: nil).last.tariff.tariff_type_id,
                              use_id:old_subscriber.use_id,
                              endowments: old_subscriber.endowments,
                              inhabitants: old_subscriber.inhabitants,
                              inhabitants_ending_at: old_subscriber.inhabitants_ending_at,
                              installation_date: old_subscriber.meter_details.first.installation_date,
                              installation_index: old_subscriber.meter_details.first.installation_reading,
                              created_by: created_by
                            )
    old_subscriber.subscriber_tariffs.where(ending_at: nil).each do |st|
        _subscriber_tariffs = st.tariff
        water_supply_contract.tariffs << _subscriber_tariffs
    end

    subscriber = old_subscriber
    subscriber.update_attributes(
      client_id: client.id,
      first_name: client.first_name,
      last_name: client.last_name,
      company: client.company,
      fiscal_id: client.fiscal_id,
      cellular: client_cellular,
      email: client_email,
      phone: client_phone,
      fax: client_fax,
      postal_first_name: client.first_name,
      postal_last_name: client.last_name,
      postal_company: client.company,
      postal_street_directory_id: client_street_directory_id,
      postal_street_type_id: client_street_type_id,
      postal_street_name: client_street_name,
      postal_street_number: client_street_number,
      postal_building: client_building,
      postal_floor: client_floor,
      postal_floor_office: client_floor_office,
      postal_zipcode_id: client_zipcode_id,
      postal_town_id: client_town_id,
      postal_province_id: client_province_id,
      postal_region_id: client_region_id,
      postal_country_id: client_country_id,
      updated_by: created_by
    )
    if old_subscriber.water_supply_contract
      self.work_order_id = old_subscriber.water_supply_contract.contracting_request.work_order_id || nil
    else
      self.work_order_id = nil
    end
    self.contracting_request_status_id = ContractingRequestStatus::COMPLETE
    self.save
  end

  #to_add_concept
  def to_add_concept
    water_supply_contract = WaterSupplyContract.create(
                              contract_no: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_no : nil,
                              contracting_request_id: id,
                              client_id: client.id,
                              subscriber_id: old_subscriber.id,
                              reading_route_id: old_subscriber.reading_route_id,
                              work_order_id: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.work_order_id : nil,
                              tariff_scheme_id: old_subscriber.tariff_scheme_id,
                              bill_id: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.bill_id : nil,
                              meter_id: old_subscriber.meter_id,
                              contract_date: request_date,
                              reading_sequence: old_subscriber.reading_sequence,
                              cadastral_reference: old_subscriber.cadastral_reference,
                              pub_record: old_subscriber.pub_record,
                              gis_id: old_subscriber.gis_id,
                              min_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.min_pressure : nil,
                              max_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.max_pressure : nil,
                              contract_term: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_term : nil,
                              remarks: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.remarks : nil,
                              caliber_id: old_subscriber.meter.caliber_id,
                              #tariff_type_id: old_subscriber.subscriber_tariffs.where(ending_at: nil).last.tariff.tariff_type_id,
                              use_id:old_subscriber.use_id,
                              endowments: old_subscriber.endowments,
                              inhabitants: old_subscriber.inhabitants,
                              inhabitants_ending_at: old_subscriber.inhabitants_ending_at,
                              installation_date: old_subscriber.meter_details.first.installation_date,
                              installation_index: old_subscriber.meter_details.first.installation_reading,
                              created_by: created_by
                            )
    old_subscriber.subscriber_tariffs.where(ending_at: nil).each do |st|
        _subscriber_tariffs = st.tariff
        water_supply_contract.tariffs << _subscriber_tariffs
    end

    subscriber = old_subscriber
    subscriber.update_attributes(
      client_id: client.id,
      first_name: client.first_name,
      last_name: client.last_name,
      company: client.company,
      fiscal_id: client.fiscal_id,
      cellular: client_cellular,
      email: client_email,
      phone: client_phone,
      fax: client_fax,
      postal_first_name: client.first_name,
      postal_last_name: client.last_name,
      postal_company: client.company,
      postal_street_directory_id: client_street_directory_id,
      postal_street_type_id: client_street_type_id,
      postal_street_name: client_street_name,
      postal_street_number: client_street_number,
      postal_building: client_building,
      postal_floor: client_floor,
      postal_floor_office: client_floor_office,
      postal_zipcode_id: client_zipcode_id,
      postal_town_id: client_town_id,
      postal_province_id: client_province_id,
      postal_region_id: client_region_id,
      postal_country_id: client_country_id,
      updated_by: created_by
    )
    if old_subscriber.water_supply_contract
      self.work_order_id = old_subscriber.water_supply_contract.contracting_request.work_order_id || nil
    else
      self.work_order_id = nil
    end
    self.contracting_request_status_id = ContractingRequestStatus::INITIAL
    self.save
  end

  def to_change_ownership
    # assign water_supply_contract to the new subscriber
    # IMPORTANTE COPIAR DATOS DE UNO A UNO Y NO COGERLOS DE WaterSupplyContract
    # water_supply_contract = WaterSupplyContract.new(old_subscriber.water_supply_contract.attributes.except!("id", "created_at", "updated_at"))
    # water_supply_contract.client = client
    water_supply_contract = WaterSupplyContract.new(
                              contract_no: contract_next_no(self.project_id,self.contracting_request_type_id),
                              contracting_request_id: id,
                              client_id: client.id,
                              reading_route_id: old_subscriber.reading_route_id,
                              meter_id: old_subscriber.meter_id,
                              tariff_scheme_id: old_subscriber.tariff_scheme_id,
                              contract_date: request_date,
                              reading_sequence: old_subscriber.reading_sequence,
                              cadastral_reference: old_subscriber.cadastral_reference,
                              pub_record: old_subscriber.pub_record,
                              gis_id: old_subscriber.gis_id,
                              min_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.min_pressure : nil,
                              max_pressure: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.max_pressure : nil,
                              contract_term: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.contract_term : nil,
                              remarks: old_subscriber.water_supply_contract ? old_subscriber.water_supply_contract.remarks : nil,
                              caliber_id: old_subscriber.meter.caliber_id,
                              endowments: old_subscriber.endowments,
                              inhabitants: old_subscriber.inhabitants,
                              inhabitants_ending_at: old_subscriber.inhabitants_ending_at,
                              use_id:old_subscriber.use_id,
                              created_by: created_by #,
                              #tariff_type_id: old_subscriber.subscriber_tariffs.where(ending_at: nil).last.tariff.tariff_type_id
                            )
    water_supply_contract.save

    old_subscriber.subscriber_tariffs.where(ending_at: nil).each do |st|
        _subscriber_tariffs = st.tariff
        water_supply_contract.tariffs << _subscriber_tariffs
    end

    #
    # @subscriber = Subscriber.new
    # @subscriber.assign_attributes(
    #   active: true,
    #   billing_frequency_id: water_supply_contract.try(:bill).try(:invoices).try(:first).try(:tariff_scheme).try(:tariffs).try(:first).try(:billing_frequency_id),
    #   building: subscriber_building,
    #   cadastral_reference: water_supply_contract.try(:cadastral_reference),
    #   cellular: entity.cellular,
    #   center_id: subscriber_center_id,
    #   client_id: water_supply_contract.client_id,
    #   # contract: ,
    #   country_id: subscriber_country_id,
    #   country_id: subscriber_country_id,
    #   email: entity.email,
    #   email: entity.email,
    #   # ending_at: ,
    #   endowments: water_supply_contract.try(:endowments),
    #   fax: entity.fax,
    #   fiscal_id: entity.fiscal_id,
    #   floor: subscriber_floor,
    #   floor_office: subscriber_floor_office,
    #   gis_id: water_supply_contract.try(:gis_id),
    #   inhabitants: water_supply_contract.try(:inhabitants),
    #   name: entity.try(:full_name),
    #   name: entity.try(:full_name),
    #   office_id: project.try(:office).try(:id),
    #   office_id: project.try(:office).try(:id),
    #   phone: entity.phone,
    #   phone: entity.phone,
    #   province_id: subscriber_province_id,
    #   province_id: subscriber_province_id,
    #   region_id: subscriber_region_id,
    #   region_id: subscriber_region_id,
    #   remarks: try(:water_supply_contract).try(:remarks),
    #   remarks: try(:water_supply_contract).try(:remarks),
    #   starting_at: Time.now,
    #   street_directory_id: subscriber_street_directory_id,
    #   street_directory_id: subscriber_street_directory_id,
    #   street_name: subscriber_street_name,
    #   street_name: subscriber_street_name,
    #   street_number: subscriber_street_number,
    #   street_number: subscriber_street_number,
    #   street_type_id: subscriber_street_type_id,
    #   street_type_id: subscriber_street_type_id,
    #   subscriber_code: sub_next_no(project.organization_id),
    #   subscriber_code: sub_next_no(project.organization_id),
    #   town_id: subscriber_town_id,
    #   zipcode_id: subscriber_zipcode_id,
    #   tariff_scheme_id: water_supply_contract.tariff_scheme_id,
    #   first_name: entity.first_name,
    #   last_name: entity.last_name,
    #   company: entity.company,
    #   meter_id: old_subscriber.meter_id,
    #   reading_route_id: old_subscriber.reading_route_id,
    #   reading_sequence: old_subscriber.reading_sequence,
    #   reading_variant: old_subscriber.reading_variant,
    #   service_point_id: old_subscriber.service_point_id
    # )
    # @reading = @subscriber.readings.build(
    #   project_id: project_id,
    #   # billing_period_id: ,
    #   billing_frequency_id: water_supply_contract.try(:bill).try(:invoices).try(:first).try(:tariff_scheme).try(:tariffs).try(:first).try(:billing_frequency_id),
    #   reading_type_id: 4, #readgin type installation
    #   meter_id: @subscriber.meter_id,
    #   reading_route_id: @subscriber.reading_route_id,
    #   reading_sequence: @subscriber.reading_sequence,
    #   reading_variant:  @subscriber.reading_variant,
    #   reading_date: Date.today,
    #   reading_index: old_subscriber.readings.last.reading_index
    # )
    # @meter_details = @subscriber.meter_details.build(installation_date: Date.today, installation_reading: old_subscriber.readings.last.reading_index, meter_id: old_subscriber.meter_id)
    # @meter_details.save
    # old_subscriber.update_attributes(ending_at: Date.today, meter_id: nil)
    # # update meter details withdrawal
    # old_subscriber.meter_details.last.update_attributes(withdrawal_date: Date.today ,
    #                                                     withdrawal_reading: old_subscriber.readings.last.reading_index)
    # if @subscriber.save
    #   water_supply_contract.update_attributes(subscriber_id: @subscriber.id)
    # else
    #   false
    # end



      # water_supply_contract.bill.update_attributes(subscriber_id: @subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
    # create new subscriber
    # to_subscriber
    # create meter details to new subscriber
    # MeterDetail.create( meter_id: subscriber.meter_id,
    #                     subscriber_id: subscriber.id,
    #                     installation_date: Date.today,
    #                     installation_reading: old_subscriber.readings.last.reading_index)
  end

  # Subscriber code
  def sub_next_no(office)
    code = ''
    office = office.to_s if office.is_a? Fixnum
    office = office.rjust(4, '0')
    last_no = Subscriber.where("subscriber_code LIKE ?", "#{office}%").order(:subscriber_code).maximum(:subscriber_code)
    if last_no.nil?
      code = office + '0000001'
    else
      last_no = last_no[4..10].to_i + 1
      code = office +  last_no.to_s.rjust(7, '0')
    end
    code
  end

  # Contracting request no
  def cr_next_no(project)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    project_code = Project.find(project).project_code rescue '$'
    if project_code == '$'
      code = '$err'
    else
      project = project_code.rjust(12, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = ContractingRequest.where("request_no LIKE ?", "#{project}#{year}%").order(:request_no).maximum(:request_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

  # Params: project_id, type_id
  def contract_next_no(project, type)
    year = Time.new.year
    last_no = nil
    code = ''
    # Builds code, if possible
    project = project.to_s if project.is_a? Fixnum
    project = project.rjust(6, '0')
    type_s = type.to_s if type.is_a? Fixnum
    type_s = type_s.rjust(2, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    if type == ContractingRequestType::CONNECTION
      last_no = WaterConnectionContract.where("contract_no LIKE ?", "#{project}#{type_s}#{year}%").order(:contract_no).maximum(:contract_no)
    else
      last_no = WaterSupplyContract.where("contract_no LIKE ?", "#{project}#{type_s}#{year}%").order(:contract_no).maximum(:contract_no)
    end
    if last_no.nil?
      code = project + type_s + year + '000001'
    else
      last_no = last_no[12..17].to_i + 1
      code = project + type_s + year + last_no.to_s.rjust(6, '0')
    end
    code
  end


  def status_control(status=nil)
    if ["INITIAL","INSPECTION","BILLING","INSTALLATION","COMPLETE"].include? status.try(:upcase)
      self.contracting_request_status_id = ContractingRequestStatus.const_get(status.try(:upcase))
    else

      if contracting_request_status_id == nil
        self.contracting_request_status_id = ContractingRequestStatus::INITIAL

      elsif contracting_request_status_id == ContractingRequestStatus::INITIAL
        self.contracting_request_status_id = ContractingRequestStatus::INSPECTION

      elsif contracting_request_status_id == ContractingRequestStatus::INSPECTION
        self.contracting_request_status_id = ContractingRequestStatus::BILLING

      elsif contracting_request_status_id == ContractingRequestStatus::BILLING
        self.contracting_request_status_id = ContractingRequestStatus::INSTALLATION

      elsif contracting_request_status_id == ContractingRequestStatus::INSTALLATION
        self.contracting_request_status_id = ContractingRequestStatus::COMPLETE
      end
    end
  end

  def iban_format_with_spaces
    iban.gsub(/(.{4})(?=.)/, '\1 \2')
  end

  private

  def check_document_required?
    document_required_ids = ContractingRequestDocumentType.where(required: true).map(&:id)
    doc_miss_id = document_required_ids - contracting_request_documents.map(&:contracting_request_document_type_id)
    doc_miss_name = ContractingRequestDocumentType.where(id: doc_miss_id).map(&:name)
    self.errors.add(:contracting_request_document_ids, I18n.t('activerecord.models.contracting_request.check_for_required_documents') + doc_miss_name.join(",")) unless doc_miss_name.blank?
  end
end
