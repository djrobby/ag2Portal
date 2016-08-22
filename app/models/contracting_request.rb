class ContractingRequest < ActiveRecord::Base
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
  belongs_to :old_subscriber, :class_name => 'Subscriber',:foreign_key => "subscriber_id"
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
                  :subscriber_zipcode_id, :iban, :country_code, :iban_dc, :cb, :cs, :ccc_dc,
                  :account_no, :work_order_id, :subscriber_id, :service_point_id, :service_point

  attr_accessible :contracting_request_documents_attributes

  has_many :contracting_request_documents
  accepts_nested_attributes_for :contracting_request_documents
  has_one :water_supply_contract
  has_one :client, through: :entity
  has_one :water_connection_contracts

  has_paper_trail

  # Nested attributes
  accepts_nested_attributes_for :contracting_request_documents, :reject_if => :all_blank, :allow_destroy => true

  # VALIDATORS
  validates_associated :contracting_request_documents
  validates :request_no,                  :presence => true,
                                          :length => { :is => 22 },
                                          :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid }
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
  validates :client_phone,                :presence => true
  validates :client_province,             :presence => true
  validates :client_region,               :presence => true
  validates :client_street_name,          :presence => true
  validates :client_street_number,        :presence => true
  validates :client_street_type,          :presence => true
  validates :client_town,                 :presence => true
  validates :client_zipcode,              :presence => true
  validates :subscriber_center,           :presence => true
  validates :subscriber_country,          :presence => true
  validates :subscriber_province,         :presence => true
  validates :subscriber_region,           :presence => true
  validates :subscriber_street_directory, :presence => true
  validates :subscriber_street_number,    :presence => true
  validates :subscriber_street_type,      :presence => true
  validates :subscriber_town,             :presence => true
  validates :subscriber_zipcode,          :presence => true
  # validates :subscriber_id, presence: true, if: "contracting_request_type_id==2"

  # CALLBACKS
  after_create :to_client #create/assign client after create contracting_request

  # Searchable attributes
  searchable do
    text :request_no
    text :client_info
    string :request_no
    string :contracting_request_type_id
    string :project_id
    string :contracting_request_status_id
    date :request_date
    string :sort_no do
      request_no
    end
  end

  # Preformated information
  def client_info
    "#{client.full_name} #{client.fiscal_id}" if client
  end

  def full_name
    full_no
  end

  def full_no
    # Request no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    request_no.blank? ? "" : request_no[0..11] + '-' + request_no[12..15] + '-' + request_no[16..21]
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
    !country_code.blank? && !iban_dc.blank? && !cb.blank? && !cs.blank? && !ccc_dc.blank? && !account_no.blank?
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
      name: entity.company.nil? ? "#{entity.last_name} #{entity.first_name} ": entity.company,
      first_name: entity.first_name,
      last_name: entity.last_name,
      company: entity.company,
      phone: client_phone,
      # remarks:,
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
      # created_by: ,
      # updated_by:,
      # is_contact:,
      # shared_contact_id:,
      # ledger_account_id:,
      payment_method_id: 1
    )
    # water_supply_contract.update_attributes(client_id: client.id) if water_supply_contract
    ClientBankAccount.create(client_id: client.id, iban: iban, country_code: string, iban_dc: iban_dc, cb: cb, cs: cs, ccc_dc: ccc_dc, account_no: account_no, fiscal_id: client.fiscal_id, name: "contratacion de servicios") if data_account?
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
      gis_id: (water_supply_contract.gis_id if water_supply_contract),
      inhabitants: (water_supply_contract.inhabitants if water_supply_contract),
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
      subscriber_code: sub_next_no(project.organization_id),
      # tariff_id: (water_supply_contract.tariff_id if water_supply_contract),
      town_id: subscriber_town_id,
      zipcode_id: subscriber_zipcode_id,
      tariff_scheme_id: water_supply_contract.tariff_scheme_id,
      service_point_id: service_point_id
    )
    water_supply_contract.update_attributes(subscriber_id: _subscriber.id) if water_supply_contract
    # self.update_attributes(subscriber_id: subscriber.id)
  end

  def to_subrogation
    # assign water_supply_contract to the new subscriber
    # IMPORTANTE COPIAR DATOS DE UNO A UNO Y NO COGERLOS DE WaterSupplyContract
    water_supply_contract = WaterSupplyContract.new(old_subscriber.water_supply_contract.attributes.except!("id", "created_at", "updated_at"))
    water_supply_contract.client = client
    water_supply_contract.contracting_request_id = id
    water_supply_contract.save
    water_supply_contract = WaterSupplyContract.new(
                              # contracting_request_id: id,
                              # client_id: client.id,
                              # subscriber_id: ,
                              # reading_route_id: ,
                              # work_order_id: ,
                              # meter_id: ,
                              # bill_id: 232,
                              # contract_date: ,
                              # reading_sequence: ,
                              # cadastral_reference: '',
                              # gis_id: '',
                              # endowments: 0,
                              # inhabitants: 0,
                              # installation_date: ,
                              # remarks: '',
                              # tariff_scheme_id: 32,
                              # caliber_id: 3
                            )

  # ending old subscriber

    @subscriber = Subscriber.new
    @subscriber.assign_attributes(
      active: true,
      billing_frequency_id: water_supply_contract.try(:bill).try(:invoices).try(:first).try(:tariff_scheme).try(:tariffs).try(:first).try(:billing_frequency_id),
      building: subscriber_building,
      cadastral_reference: water_supply_contract.try(:cadastral_reference),
      cellular: entity.cellular,
      center_id: subscriber_center_id,
      client_id: water_supply_contract.client_id,
      # contract: ,
      country_id: subscriber_country_id,
      country_id: subscriber_country_id,
      email: entity.email,
      email: entity.email,
      # ending_at: ,
      endowments: water_supply_contract.try(:endowments),
      fax: entity.fax,
      fiscal_id: entity.fiscal_id,
      floor: subscriber_floor,
      floor_office: subscriber_floor_office,
      gis_id: water_supply_contract.try(:gis_id),
      inhabitants: water_supply_contract.try(:inhabitants),
      name: entity.try(:full_name),
      name: entity.try(:full_name),
      office_id: project.try(:office).try(:id),
      office_id: project.try(:office).try(:id),
      phone: entity.phone,
      phone: entity.phone,
      province_id: subscriber_province_id,
      province_id: subscriber_province_id,
      region_id: subscriber_region_id,
      region_id: subscriber_region_id,
      remarks: try(:water_supply_contract).try(:remarks),
      remarks: try(:water_supply_contract).try(:remarks),
      starting_at: Time.now,
      street_directory_id: subscriber_street_directory_id,
      street_directory_id: subscriber_street_directory_id,
      street_name: subscriber_street_name,
      street_name: subscriber_street_name,
      street_number: subscriber_street_number,
      street_number: subscriber_street_number,
      street_type_id: subscriber_street_type_id,
      street_type_id: subscriber_street_type_id,
      subscriber_code: sub_next_no(project.organization_id),
      subscriber_code: sub_next_no(project.organization_id),
      town_id: subscriber_town_id,
      zipcode_id: subscriber_zipcode_id,
      tariff_scheme_id: water_supply_contract.tariff_scheme_id,
      first_name: entity.first_name,
      last_name: entity.last_name,
      company: entity.company,
      meter_id: old_subscriber.meter_id,
      reading_route_id: old_subscriber.reading_route_id,
      reading_sequence: old_subscriber.reading_sequence,
      reading_variant: old_subscriber.reading_variant,
      service_point_id: old_subscriber.service_point_id
    )
    @reading = @subscriber.readings.build(
      project_id: project_id,
      # billing_period_id: ,
      billing_frequency_id: water_supply_contract.try(:bill).try(:invoices).try(:first).try(:tariff_scheme).try(:tariffs).try(:first).try(:billing_frequency_id),
      reading_type_id: 4, #readgin type installation
      meter_id: @subscriber.meter_id,
      reading_route_id: @subscriber.reading_route_id,
      reading_sequence: @subscriber.reading_sequence,
      reading_variant:  @subscriber.reading_variant,
      reading_date: Date.today,
      reading_index: old_subscriber.readings.last.reading_index
    )
    @meter_details = @subscriber.meter_details.build(installation_date: Date.today, installation_reading: old_subscriber.readings.last.reading_index, meter_id: old_subscriber.meter_id)
    @meter_details.save
    old_subscriber.update_attributes(ending_at: Date.today, meter_id: nil)
    # update meter details withdrawal
    old_subscriber.meter_details.last.update_attributes(withdrawal_date: Date.today ,
                                                        withdrawal_reading: old_subscriber.readings.last.reading_index)
    if @subscriber.save
      water_supply_contract.update_attributes(subscriber_id: @subscriber.id)
    else
      false
    end
      # water_supply_contract.bill.update_attributes(subscriber_id: @subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
    # create new subscriber
    # to_subscriber
    # create meter details to new subscriber
    # MeterDetail.create( meter_id: subscriber.meter_id,
    #                     subscriber_id: subscriber.id,
    #                     installation_date: Date.today,
    #                     installation_reading: old_subscriber.readings.last.reading_index)
  end

  # Subscriber order no
  def sub_next_no(organization)
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    last_no = Subscriber.where("subscriber_code LIKE ?", "#{organization}%").order(:subscriber_code).maximum(:subscriber_code)
    if last_no.nil?
      code = organization + '000001'
    else
      last_no = last_no[4..9].to_i + 1
      code = organization +  last_no.to_s.rjust(6, '0')
    end
    code
  end

  def status_control(status=nil)
    if ["INITIAL","INSPECTION","BILLING","INSTALLATION","COMPLETE"].include? status.upcase
      self.contracting_request_status_id = ContractingRequestStatus.const_get(status.upcase)
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
end
