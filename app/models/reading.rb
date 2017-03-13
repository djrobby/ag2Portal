class Reading < ActiveRecord::Base
  belongs_to :project
  # belongs_to :bill
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
                  :meter_id, :subscriber_id, :reading_route_id, :reading_index_1, :bill_id,
                  :reading_index_2, :reading_incidence_types, :reading_1, :reading_2, :reading_1_id, :reading_2_id,
                  :created_by, :updated_by, :lat, :lng

  #:reading_incidence_types_attributtes

  attr_accessor :reading_index_add, :reading_date_add, :meter_location_id, :q_reading_index, :q_reading_date, :q_billing_period_id, :q_reading_incidence_type_ids, :a_reading_index, :a_reading_date, :a_billing_period, :a_reading_incidence_type_ids

  has_many :reading_incidences
  has_one :bill, foreign_key: "reading_2_id"

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
  scope :by_period_date, -> { order('billing_period_id desc, reading_date desc, reading_index') }
  scope :by_id_desc, -> { order('id desc') }

  def self.to_csv(array)
      attributes = [I18n.t('activerecord.attributes.reading.reading_route_id'), I18n.t('activerecord.attributes.reading.sequence'), I18n.t('activerecord.attributes.reading.subscriber'), I18n.t('activerecord.attributes.reading.address'), I18n.t('activerecord.attributes.reading.meter'), I18n.t('activerecord.attributes.reading.billing_period_2'), I18n.t('activerecord.attributes.reading.reading_2_date'), I18n.t('activerecord.attributes.reading.reading_2_index'), I18n.t('activerecord.attributes.reading.reading_days'), I18n.t('activerecord.attributes.reading.consumption_2'), I18n.t('activerecord.attributes.reading.billing_period_1'), I18n.t('activerecord.attributes.reading.reading_1_date'), I18n.t('activerecord.attributes.reading.reading_1_index'), I18n.t('activerecord.attributes.reading.billing_period_id'), I18n.t('activerecord.attributes.reading.reading_date'), I18n.t('activerecord.attributes.reading.reading'), I18n.t('activerecord.attributes.reading.reading_days'), I18n.t('activerecord.attributes.reading.consumption'), I18n.t('activerecord.report.reading.incidences') ]
    CSV.generate(headers: true) do |csv|
      csv << attributes
      array.each do |reading|
        csv << [ reading.try(:reading_route).try(:to_label),reading.reading_sequence, reading.try(:subscriber).try(:to_label), reading.try(:subscriber).try(:address_1), reading.try(:meter).try(:to_label),reading.reading_2.try(:billing_period).try(:period), reading.reading_2.try(:to_reading_date), reading.reading_2.try(:reading_index), reading.reading_2.try(:reading_days), reading.reading_2.try(:consumption_total_period), reading.reading_1.try(:billing_period).try(:period), reading.reading_1.try(:to_reading_date), reading.reading_1.try(:reading_index),reading.try(:billing_period).try(:period), reading.to_reading_date, reading.reading_index, reading.try(:reading_days), reading.try(:consumption_total_period), reading.reading_incidence_types.pluck(:name).join(", ")]
        # csv << [ reading.try(:reading_route).try(:to_label),reading.reading_sequence, reading.try(:subscriber).try(:to_label), reading.try(:subscriber).try(:address_1), reading.try(:meter).try(:to_label), reading.try(:billing_period).try(:period),reading.reading_index_2,reading.reading_index_1,reading.reading_index,reading.consumption_total_period]
      end
    end
  end

  def to_label
    "#{reading_index} - #{reading_date.strftime("%d/%m/%Y %H:%M")}" if reading_date
  end

  def to_reading_date
    "#{reading_date.strftime("%d/%m/%Y %H:%M")}" if reading_date
  end

  def reading_days
    ((reading_date.to_time - reading_1.reading_date.to_time)/86400).to_i  if reading_date
  end

  def incidences
    _codes = ""
    _ii = reading_incidences.group(:reading_incidence_type_id)
    _ii.each do |r|
      if _codes == ""
        _codes += r.reading_incidence_type.code
      else
        _codes += ("-" + r.reading_incidence_type.code)
      end
    end
    _codes
  end

  def billable?
    # reading_type_id != 4 and (bill.nil? or !Invoice.where(original_invoice_id: bill.try(:invoices).try(:first).try(:id)).blank?)
    # bill.nil? or !Invoice.where(original_invoice_id: bill.try(:invoices).try(:first).try(:id)).blank?
    if bill.blank?
      Reading.where(subscriber_id: subscriber_id, billing_period_id: billing_period_id, reading_type_id: [ReadingType::NORMAL, ReadingType::OCTAVILLA, ReadingType::RETIRADA, ReadingType::AUTO]).select{|r| r.bill != nil}.blank?
    else
      false #!Invoice.where(original_invoice_id: bill.try(:invoices).try(:first).try(:id)).blank?
    end
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
      0
    end
  rescue
    0
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

  def sort_id
    self.id
  end

  def generate_pre_bill(group_no=nil,user_id=nil,operation_id=1)
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

    #subscriber.tariff_scheme.tariffs_supply(meter.caliber_id).each do |tariffs_biller|
    subscriber.tariffs_supply.each do |tariffs_biller|
      pre_invoice = PreInvoice.create(
        invoice_no: nil, #invoice_next_no(project.company_id),
        pre_bill_id: pre_bill.id,
        invoice_status_id: InvoiceStatus::PENDING,
        invoice_type_id: InvoiceType::WATER,
        invoice_date: billing_period.try(:prebilling_starting_date),#¿¿¿???
        tariff_scheme_id: subscriber.tariff_scheme_id,
        payday_limit: billing_period.try(:prebilling_ending_date),
        invoice_operation_id: operation_id,
        billing_period_id: billing_period_id,
        consumption: consumption_total_period,
        consumption_real: consumption_total_period,
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
            price: (tariff.fixed_fee / tariff.billing_frequency.total_months),
            quantity: billing_frequency.total_months,
            tax_type_id: tariff.try(:tax_type_f_id),
            discount_pct: tariff.try(:discount_pct_f),
            discount: 0.0,#¿¿¿???
            product_id: nil,
            subcode: "CF",
            measure_id: tariff.billing_frequency.fix_measure_id)
        end
        if tariff.block1_fee > 0
          limit_before = 0
          (1..8).each do |i|
            # if limit nil (last block) or limit > consumption
            if tariff.instance_eval("block#{i}_limit").nil? || tariff.instance_eval("block#{i}_limit") > (consumption_total_period || 0)
              PreInvoiceItem.create(
                pre_invoice_id: pre_invoice.id,
                code: tariff.try(:billable_item).try(:billable_concept).try(:code),
                description: tariff.try(:billable_item).try(:billable_concept).try(:name),
                tariff_id: tariff.id,
                price:  tariff.instance_eval("block#{i}_fee"),
                quantity: ((consumption_total_period || 0) - limit_before),
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
        elsif tariff.percentage_fee > 0 and !tariff.percentage_applicable_formula.blank?
          PreInvoiceItem.create(
            pre_invoice_id: pre_invoice.id,
            code: tariff.try(:billable_item).try(:billable_concept).try(:code),
            description: tariff.try(:billable_item).try(:billable_concept).try(:name),
            tariff_id: tariff.id,
            price:  (tariff.percentage_fee/100) * pre_bill.total_by_concept(tariff.percentage_applicable_formula) / consumption_total_period,
            quantity: consumption_total_period,
            tax_type_id: tariff.try(:tax_type_p_id),
            discount_pct: tariff.try(:discount_pct_p),
            discount: 0.0,#¿¿¿???
            product_id: nil,
            subcode: "VP",
            measure_id: tariff.billing_frequency.var_measure_id)
        elsif tariff.variable_fee > 0
          PreInvoiceItem.create(
            pre_invoice_id: pre_invoice.id,
            code: tariff.try(:billable_item).try(:billable_concept).try(:code),
            description: tariff.try(:billable_item).try(:billable_concept).try(:name),
            tariff_id: tariff.id,
            price:  tariff.variable_fee,
            quantity: consumption_total_period,
            tax_type_id: tariff.try(:tax_type_v_id),
            discount_pct: tariff.try(:discount_pct_v),
            discount: 0.0,#¿¿¿???
            product_id: nil,
            subcode: "CV",
            measure_id: tariff.billing_frequency.var_measure_id)
        end
      end
    end
    return pre_bill
  end

  def generate_bill(next_bill_no=nil,user_id=nil,operation_id=1,payday_limit=nil,invoice_date=nil)
    if Bill.select{|b| b.bill_operation == operation_id and b.bill_period == billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == subscriber_id}.blank?
      @bill = Bill.create!(
        bill_no: next_bill_no,
        project_id: project_id,
        invoice_status_id: InvoiceStatus::PENDING,
        bill_date: invoice_date,
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
        created_by: user_id,
        reading_1_id: reading_1.try(:id),
        reading_2_id: id,
        organization_id: project.organization_id )
      subscriber.tariffs_supply.each do |tariffs_biller|
        @invoice = Invoice.create!(
          invoice_no: invoice_next_no(project.company_id, project.office_id),
          bill_id: @bill.id,
          invoice_status_id: InvoiceStatus::PENDING,
          invoice_type_id: InvoiceType::WATER,
          invoice_date: invoice_date,
          tariff_scheme_id: nil,
          payday_limit: payday_limit.blank? ? invoice_date : payday_limit,
          invoice_operation_id: operation_id,
          billing_period_id: billing_period_id,
          consumption: consumption_total_period,
          consumption_real: consumption_total_period,
          consumption_estimated: nil,
          consumption_other: nil,
          biller_id: tariffs_biller[0],
          discount_pct: 0.0,
          exemption: 0.0,
          charge_account_id: 1,
          created_by: user_id,
          reading_1_date: reading_1.try(:reading_date),
          reading_2_date: reading_date,
          reading_1_index: reading_1.try(:reading_index),
          reading_2_index: reading_index,
          organization_id: project.organization_id )
        tariffs_biller[1].each do |tariff|
          unless tariff.fixed_fee.zero?
            InvoiceItem.create(
              invoice_id: @invoice.id,
              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
              tariff_id: tariff.id,
              price: (tariff.fixed_fee / tariff.billing_frequency.total_months),
              quantity: billing_frequency.total_months,
              tax_type_id: tariff.try(:tax_type_f_id),
              discount_pct: tariff.try(:discount_pct_f),
              discount: 0.0,#¿¿¿???
              product_id: nil,
              subcode: "CF",
              measure_id: tariff.billing_frequency.fix_measure_id,
              created_by: user_id )
          end
          if tariff.block1_fee > 0
            limit_before = 0
            (1..8).each do |i|
              # if limit nil (last block) or limit > consumption
              if tariff.instance_eval("block#{i}_limit").nil? || tariff.instance_eval("block#{i}_limit") > (consumption_total_period || 0)
                InvoiceItem.create(
                  invoice_id: @invoice.id,
                  code: tariff.try(:billable_item).try(:billable_concept).try(:code),
                  description: tariff.try(:billable_item).try(:billable_concept).try(:name),
                  tariff_id: tariff.id,
                  price:  tariff.instance_eval("block#{i}_fee"),
                  quantity: ((consumption_total_period || 0) - limit_before),
                  tax_type_id: tariff.try(:tax_type_b_id),
                  discount_pct: tariff.try(:discount_pct_b),
                  discount: 0.0,#¿¿¿???
                  product_id: nil,
                  subcode: "BL"+i.to_s,
                  measure_id: tariff.billing_frequency.var_measure_id,
                  created_by: user_id )
                break
              else
                InvoiceItem.create(
                  invoice_id: @invoice.id,
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
                  measure_id: tariff.billing_frequency.var_measure_id,
                  created_by: user_id )
                limit_before = tariff.instance_eval("block#{i}_limit")
              end
            end
          elsif tariff.percentage_fee > 0 and !tariff.percentage_applicable_formula.blank?
            InvoiceItem.create(
              invoice_id: @invoice.id,
              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
              tariff_id: tariff.id,
              price:  (tariff.percentage_fee/100) * @bill.total_by_concept(tariff.percentage_applicable_formula) / consumption_total_period,
              quantity: consumption_total_period,
              tax_type_id: tariff.try(:tax_type_p_id),
              discount_pct: tariff.try(:discount_pct_p),
              discount: 0.0,#¿¿¿???
              product_id: nil,
              subcode: "VP",
              measure_id: tariff.billing_frequency.var_measure_id,
              created_by: user_id )
          elsif tariff.variable_fee > 0
            InvoiceItem.create(
              invoice_id: @invoice.id,
              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
              tariff_id: tariff.id,
              price:  tariff.variable_fee,
              quantity: consumption_total_period,
              tax_type_id: tariff.try(:tax_type_v_id),
              discount_pct: tariff.try(:discount_pct_v),
              discount: 0.0,#¿¿¿???
              product_id: nil,
              subcode: "CV",
              measure_id: tariff.billing_frequency.var_measure_id,
              created_by: user_id )
          end
        end
      end
      self.bill_id = @bill.id
      self.save
      return @bill
    else
      return nil
    end
  end

  # Real consumption (by period)
  def consumption_total_period
    # @readings = Reading.where(billing_period_id: billing_period_id, subscriber_id: subscriber_ids).where('reading_type_id NOT IN (?)',[1,2,5,6]).group_by(&:reading_1_id)
    readings = subscriber.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    total = 0
    readings.each do |reading|
      total += reading[1].last.consumption
    end
    return total
  end

  # Estimated consumption
  def estimated_consumption
    total = 0
    # if real consumption equals zero, try to estimate
    if consumption_total_period == 0
      # Only estimates if there is an incidence that requires estimating
      if ReadingIncidence.reading_should_be_estimated(self.id)
      end
    end
    total
  end

  searchable do
    text :subscriber_code_name_address_fiscal do
      subscriber.code_full_name_or_company_address_fiscal unless subscriber.blank?
    end
    text :meter_code do
      meter.meter_code unless meter.blank?
    end
    integer :id, :multiple => true          # Multiple search values accepted in one search (current_projects)
    integer :subscriber_id
    integer :meter_id
    integer :billing_period_id
    integer :project_id, :multiple => true  # Multiple search values accepted in one search (current_projects)
    integer :reading_route_id
    time :reading_date
    integer :reading_index
    date :created_at
    string :sort_no do
      subscriber_id
    end
    integer :sort_id do
      sort_id
    end
  end

  private

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
