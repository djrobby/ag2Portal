class WaterConnectionContract < ActiveRecord::Base
  belongs_to :contracting_request
  belongs_to :water_connection_type
  belongs_to :client
  belongs_to :work_order
  belongs_to :sale_offer
  belongs_to :tariff
  belongs_to :bill
  belongs_to :caliber
  belongs_to :tariff_type
  belongs_to :tariff_scheme
  belongs_to :service_point_purpose


  attr_accessible :contract_date, :remarks, :contracting_request_id, :water_connection_type_id,
                  :client_id, :work_order_id, :sale_offer_id, :tariff_id, :bill_id, :contract_no,
                  :caliber_id, :tariff_type_id, :service_point_purpose_id, :cadastral_reference,
                  :gis_id, :min_pressure, :max_pressure, :connections_no, :dwellings_no, :premises_no,
                  :common_items_no, :premises_area, :yard_area, :pipe_length, :pool_area, :diameter,
                  :tariff_scheme_id, :created_by, :updated_by

  attr_accessible :water_connection_contract_items_attributes

  has_many :water_connection_contract_items, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :water_connection_contract_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  # validates
  validates_associated :water_connection_contract_items

  # methods
  def to_sale_offer
    sale_offer = SaleOffer.create(
      organization_id: contracting_request.project.organization.id,
      project_id: contracting_request.project_id,         
      offer_no: sale_offer_next_no(contracting_request.project),
      offer_date: contracting_request.request_date,
      sale_offer_status_id: 1,
      client_id: client_id,
      contracting_request_id: contracting_request_id,
      payment_method_id: contracting_request.client.active_bank_account ? 6 : 1,
      charge_account_id: water_connection_type_id == WaterConnectionType::SUM ? 10763 : water_connection_type_id == WaterConnectionType::SAN ? 10764 : ""
    )
  end
  
  def full_no
    # Contract no (Project Id & Request type Id & year & sequential number) => PPPPPP-TT-YYYY-NNNNNN
    contract_no.blank? ? "" : contract_no[0..5] + '-' + contract_no[6..7] + '-' + contract_no[8..11] + '-' + contract_no[12..17]
  end

  def request_no
    contracting_request.request_no unless contracting_request.blank?
  end

  def flow
    water_connection_contract_items.reject(&:marked_for_destruction?).sum(&:quantity_flow)
  end

  def connection_price
    _a = "26.69".to_f #connection_fee_a
    _a *= (!diameter.blank? && diameter > 0) ? diameter : caliber.caliber
    _b = flow != 0 ? "182.28".to_f * flow : "182.28".to_f #connection_fee_a
    _a + _b
  end

  searchable do
    integer :id
    integer :contracting_request_id
    integer :caliber_id
    date :contract_date
    string :request_no do
      request_no
    end
  end

  def generate_bill
    bill = Bill.create( bill_no: bill_next_no(contracting_request.project),
                        project_id: contracting_request.project_id,
                        invoice_status_id: InvoiceStatus::PENDING,
                        bill_date: Date.today,
                        client_id: client_id,
                        last_name: client.last_name,
                        first_name: client.first_name,
                        company: client.company,
                        fiscal_id: client.fiscal_id,
                        street_type_id: client.street_type_id,
                        street_name: client.street_name,
                        street_number: client.street_number,
                        building: client.building,
                        floor: client.floor,
                        floor_office: client.floor_office,
                        zipcode_id: client.zipcode_id,
                        town_id: client.town_id,
                        province_id: client.province_id,
                        region_id: client.region_id,
                        country_id: client.country_id,
                        organization_id: contracting_request.project.organization_id,
                        created_by: contracting_request.try(:created_by) )
      tariff_scheme.tariffs_contract(caliber_id).each do |tariffs_biller|
        invoice = Invoice.create( invoice_no: invoice_next_no(contracting_request.try(:project).try(:company_id), contracting_request.try(:project).try(:office_id)),
                                bill_id: bill.id,
                                invoice_status_id: InvoiceStatus::PENDING,
                                invoice_type_id: InvoiceType::CONTRACT,
                                invoice_date: Date.today,
                                tariff_scheme_id: tariff_scheme.id,
                                payday_limit: Date.today,
                                invoice_operation_id: InvoiceOperation::INVOICE,
                                billing_period_id: nil,
                                consumption: nil,
                                consumption_real: nil,
                                consumption_estimated: nil,
                                consumption_other: nil,
                                biller_id: tariffs_biller[0],
                                discount_pct: 0.0,
                                exemption: 0.0,
                                original_invoice_id: nil,
                                charge_account_id: contracting_request.project.try(:charge_accounts).first.try(:id),
                                organization_id: contracting_request.project.organization_id,
                                created_by: contracting_request.try(:created_by) )
        tariffs_biller[1].each do |tariff|
          _a = tariff.try(:connection_fee_a).to_f
          _a *= (!diameter.blank? && diameter > 0) ? diameter : caliber.caliber
          _b = flow != 0 ? tariff.try(:connection_fee_b).to_f * flow : tariff.try(:connection_fee_b).to_f * flow
          connection_price = _a + _b
          InvoiceItem.create( invoice_id: invoice.id,
                              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
                              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
                              tariff_id: tariff.id,
                              price: connection_price,
                              quantity: 1,
                              tax_type_id: tariff.try(:tax_type_f_id),
                              discount_pct: tariff.try(:discount_pct_f),
                              discount: 0.0,
                              product_id: nil,
                              subcode: tariff.try(:billable_item).try(:billable_concept).try(:code),
                              measure_id: tariff.billing_frequency.fix_measure_id,
                              created_by: contracting_request.try(:created_by) )
      end
      _i = Invoice.find(invoice.id)
      _i.totals = _i.total
      _i.save
    end
    self.bill_id = bill.id
    if self.save
      return bill
    else
      return nil
    end
  end

  private

    # Sale offer no
  def sale_offer_next_no(project)
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
      last_no = SaleOffer.where("offer_no LIKE ?", "#{project}#{year}%").order(:offer_no).maximum(:offer_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

    # Bill no
    def bill_next_no(project)
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
        last_no = Bill.where("bill_no LIKE ?", "#{project}#{year}%").order(:bill_no).maximum(:bill_no)
        if last_no.nil?
          code = project + year + '0000001'
        else
          last_no = last_no[16..22].to_i + 1
          code = project + year + last_no.to_s.rjust(7, '0')
        end
      end
      code
    end

    # Invoice no
    def invoice_next_no(company, office = nil)
      year = Time.new.year
      code = ''
      serial = ''
      office_code = office.nil? ? '00' : office.to_s.rjust(2, '0')
      # Builds code, if possible
      company_code = Company.find(company).invoice_code rescue '$'
      if company_code == '$'
        code = '$err'
      else
        serial = company_code.rjust(3, '0') + office_code
        year = year.to_s if year.is_a? Fixnum
        year = year.rjust(4, '0')
        last_no = Invoice.where("invoice_no LIKE ?", "#{serial}#{year}%").order(:invoice_no).maximum(:invoice_no)
        if last_no.nil?
          code = serial + year + '0000001'
        else
          last_no = last_no[9..15].to_i + 1
          code = serial + year + last_no.to_s.rjust(7, '0')
        end
      end
      code
    end
  end