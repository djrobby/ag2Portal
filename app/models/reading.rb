class Reading < ActiveRecord::Base

  belongs_to :project
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :reading_route
  belongs_to :reading_1, class_name: "Reading"
  belongs_to :reading_2, class_name: "Reading"
  has_and_belongs_to_many :reading_incidence_types, join_table: "reading_incidences"

  attr_accessible :reading_date, :reading_index, :reading_sequence, :reading_variant,
                  :project_id, :billing_period_id, :billing_frequency_id, :reading_type_id,
                  :meter_id, :subscriber_id, :reading_route_id, :reading_index_1,
                  :reading_index_2, :reading_incidence_types, :reading_1, :reading_2, :reading_1_id, :reading_2_id

  #:reading_incidence_types_attributtes

  attr_accessor :reading_index_add, :reading_date_add

  has_many :reading_incidences

  has_paper_trail

  validates :project,                       :presence => true
  validates :billing_period,                :presence => true
  validates :billing_frequency,             :presence => true
  validates :reading_type,                  :presence => true
  validates :meter,                         :presence => true
  validates :subscriber,                    :presence => true
  validates :reading_route,                 :presence => true
  validates :reading_date,                  :presence => true
  validates_numericality_of :reading_index, :only_integer => true,
                                            :greater_than_or_equal_to => 0,
                                            :message => :reading_invalid

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }

  def to_label
    "#{reading_index} - #{reading_date.strftime("%d/%m/%Y %H:%M")}" if reading_date
  end

  def consumption
    unless reading_index_1.nil? or reading_index.nil?
      if reading_index_1 <= reading_index
        reading_index - reading_index_1
      else
        # vuelta de contador
        ((10 ** meter.meter_model.digits) - reading_index_1) + reading_index
      end
    else
      nil
    end
  end

  def price(tariff)
    aux = 0
    total = 0
    (1..8).each do |i|
      # if limit nil (last block) or limit > consumption
      if tariff.instance_eval("block#{i}_limit").nil? || tariff.instance_eval("block#{i}_limit") > consumption
        total = total + (((consumption || 0) - aux) * tariff.instance_eval("block#{i}_fee"))
        break
      else
        total = total + ((tariff.instance_eval("block#{i}_limit") - aux) * tariff.instance_eval("block#{i}_fee"))
        aux = tariff.instance_eval("block#{i}_limit")
      end
    end
    return total + tariff.fixed_fee
  end

  def generate_pre_bill(group_no=nil,user_id=nil)
    pre_bill = PreBill.create( bill_no: nil, #bill_next_no(subscriber.contracting_request.project),
                        pre_group_no: (group_no || PreBill.next_no),
                        project_id: project_id,
                        invoice_status_id: InvoiceStatus::PENDING,
                        bill_date: (billing_period.try(:prebilling_starting_date) || Date.today),#¿¿¿???
                        subscriber_id: subscriber_id,
                        client_id: subscriber.client_id,
                        last_name: subscriber.client.last_name,
                        first_name: subscriber.client.first_name,
                        company: subscriber.client.company,
                        fiscal_id: subscriber.client.fiscal_id,
                        street_type_id: subscriber.client.street_type_id,
                        street_name: subscriber.client.street_name,
                        street_number: subscriber.client.street_number,
                        building: subscriber.client.building,
                        floor: subscriber.client.floor,
                        floor_office: subscriber.client.floor_office,
                        zipcode_id: subscriber.client.zipcode_id,
                        town_id: subscriber.client.town_id,
                        province_id: subscriber.client.province_id,
                        region_id: subscriber.client.region_id,
                        country_id: subscriber.client.country_id,
                        confirmation_date: nil,
                        bill_id: nil,
                        created_by: user_id,
                        reading_1_id: reading_1.try(:id),
                        reading_2_id: id)

    subscriber.tariff_scheme.tariffs_supply(meter.caliber_id).each do |tariffs_biller|

      pre_invoice = PreInvoice.create(
        invoice_no: nil, #invoice_next_no(project.company_id),
        pre_bill_id: pre_bill.id,
        invoice_status_id: InvoiceStatus::PENDING,
        invoice_type_id: InvoiceType::WATER,
        invoice_date: billing_period.try(:prebilling_starting_date),#¿¿¿???
        tariff_scheme_id: subscriber.tariff_scheme_id,
        payday_limit: billing_period.try(:prebilling_ending_date),
        invoice_operation_id: InvoiceOperation::INVOICE,
        billing_period_id: billing_period_id,
        consumption: consumption,
        consumption_real: consumption,
        consumption_estimated: nil,#¿¿¿???
        consumption_other: nil,#¿¿¿???
        biller_id: tariffs_biller[0],
        discount_pct: 0.0,#¿¿¿???
        exemption: 0.0,#¿¿¿???
        charge_account_id: subscriber.client.client_bank_accounts.active.first.try(:id),
        reading_1_date: reading_1.try(:reading_date),
        reading_2_date: reading_date,
        reading_1_index: reading_1.try(:reading_index),
        reading_2_index: reading_index
      )

      tariffs_biller[1].each do |tariff|
        unless tariff.fixed_fee.zero?
          PreInvoiceItem.create(
            pre_invoice_id: pre_invoice.id,
            code: tariff.try(:billable_item).try(:billable_concept).try(:code),
            description: tariff.try(:billable_item).try(:billable_concept).try(:name),
            tariff_id: tariff.id,
            price: tariff.fixed_fee,
            quantity: billing_frequency.total_months,
            tax_type_id: tariff.try(:tax_type_f_id),
            discount_pct: tariff.try(:discount_pct_f),
            discount: 0.0,#¿¿¿???
            product_id: nil,
            subcode: "CF",
            measure_id: tariff.billing_frequency.fix_measure_id)
        end
        limit_before = 0
        (1..8).each do |i|
          # if limit nil (last block) or limit > consumption
          if tariff.instance_eval("block#{i}_limit").nil? || tariff.instance_eval("block#{i}_limit") > (consumption || 0)
            PreInvoiceItem.create(
              pre_invoice_id: pre_invoice.id,
              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
              tariff_id: tariff.id,
              price:  tariff.instance_eval("block#{i}_fee"),
              quantity: ((consumption || 0) - limit_before),
              tax_type_id: tariff.try(:tax_type_b_id),
              discount_pct: tariff.try(:discount_pct_b),
              discount: 0.0,#¿¿¿???
              product_id: nil,
              subcode: "BL"+i.to_s,
              measure_id: tariff.billing_frequency.var_measure_id)
            break
          else
            PreInvoiceItem.create(
              pre_invoice_id: pre_invoice.id,
              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
              tariff_id: tariff.id,
              price:  tariff.instance_eval("block#{i}_fee"),
              quantity: tariff.instance_eval("block#{i}_limit") - limit_before,
              tax_type_id: tariff.try(:tax_type_b_id),
              discount_pct: tariff.try(:discount_pct_b),
              discount: 0.0,#¿¿¿???
              product_id: nil,
              subcode: "BL"+i.to_s,
              measure_id: tariff.billing_frequency.var_measure_id)
            limit_before = tariff.instance_eval("block#{i}_limit")
          end
        end
      end
    end
    return pre_bill
  end

  searchable do
    integer :id, :multiple => true          # Multiple search values accepted in one search (current_projects)
    integer :subscriber_id
    integer :meter_id
    integer :billing_period_id
    integer :project_id, :multiple => true  # Multiple search values accepted in one search (current_projects)
    integer :reading_route_id
    time :reading_date
    string :sort_no do
      subscriber_id
    end
    date :created_at
  end

  private
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
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

  def invoice_next_no(company)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    company_code = Company.find(company).invoice_code rescue '$'
    if company_code == '$'
      code = '$err'
    else
      company = company_code.rjust(4, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = Invoice.where("invoice_no LIKE ?", "#{company}#{year}%").order(:invoice_no).maximum(:invoice_no)
      if last_no.nil?
        code = company + year + '000001'
      else
        last_no = last_no[8..14].to_i + 1
        code = company + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

end
