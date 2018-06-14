# encoding: utf-8

class Reading < ActiveRecord::Base
  include ModelsModule

  belongs_to :project
  # belongs_to :bill
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :service_point
  belongs_to :reading_route
  belongs_to :reading_1, class_name: "Reading"  # Previous (period) reading
  belongs_to :reading_2, class_name: "Reading"  # Previous year reading
  has_and_belongs_to_many :reading_incidence_types, join_table: "reading_incidences"

  attr_accessible :reading_date, :reading_index, :reading_sequence, :reading_variant,
                  :project_id, :billing_period_id, :billing_frequency_id, :reading_type_id,
                  :meter_id, :subscriber_id, :service_point_id, :bill_id,
                  :reading_route_id, :reading_index_1, :reading_index_2,
                  :reading_incidence_types, :reading_1, :reading_2, :reading_1_id, :reading_2_id,
                  :created_by, :updated_by, :lat, :lng, :coefficient

  #:reading_incidence_types_attributtes

  attr_accessor :reading_index_add, :reading_date_add, :meter_location_id, :q_reading_index, :q_reading_date, :q_billing_period_id, :q_reading_incidence_type_ids, :a_reading_index, :a_reading_date, :a_billing_period, :a_reading_incidence_type_ids, :meter_code_input

  has_many :reading_incidences
  has_one :bill, foreign_key: "reading_2_id"
  has_one :subscriber_filiation, foreign_key: "subscriber_id"

  has_paper_trail

  validates :project,                       :presence => true
  validates :billing_period,                :presence => true
  validates :billing_frequency,             :presence => true
  validates :reading_type,                  :presence => true
  validates :meter,                         :presence => true
  # validates :subscriber,                    :presence => true
  validates :reading_route,                 :presence => true
  validates :reading_date,                  :presence => true
  validates_numericality_of :reading_index, :only_integer => true,
                                            :greater_than_or_equal_to => 0,
                                            :message => :reading_invalid

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }
  scope :by_period_date, -> { joins("LEFT JOIN billing_periods ON readings.billing_period_id=billing_periods.id").order('billing_periods.period DESC,readings.reading_date DESC,readings.id DESC') }
  scope :by_id_desc, -> { order('id desc') }
  #
  scope :unbilled, -> { where(bill_id: nil, reading_type_id: ReadingType.without_control) }
  scope :unbilled_by_subscriber, -> s { unbilled.where(subscriber_id: s) }
  scope :by_subscriber_full, -> s {
    joins(:billing_period, :reading_type, [meter: :meter_model])
    .joins('LEFT JOIN service_points ON readings.service_point_id=service_points.id')
    .joins('LEFT JOIN (reading_incidences INNER JOIN reading_incidence_types ON reading_incidences.reading_incidence_type_id=reading_incidence_types.id) ON reading_incidences.reading_id=readings.id')
    .where('readings.subscriber_id = ?', s)
    .select("readings.id, readings.meter_id, readings.subscriber_id, readings.service_point_id, readings.reading_type_id,
             meters.meter_code, billing_periods.period, reading_types.name reading_type_name,
             readings.reading_date, readings.reading_index,
             GROUP_CONCAT(reading_incidence_types.code) reading_incidence_types_pluck, readings.reading_index_1,
             CASE ISNULL(readings.reading_index) OR ISNULL(readings.reading_index_1) WHEN TRUE THEN 0 ELSE (CASE WHEN readings.reading_index_1 <= readings.reading_index THEN readings.reading_index-readings.reading_index_1 ELSE ((POWER(10,meter_models.digits)-1)-readings.reading_index_1) + readings.reading_index END) END consumption_,
             readings.id reading_id, readings.bill_id, ISNULL(readings.bill_id) is_billable, readings.coefficient, readings.coefficient > 1 is_shared,
             CASE ISNULL(service_points.code) WHEN TRUE THEN '' ELSE CONCAT(SUBSTR(service_points.code,1,4),'-',SUBSTR(service_points.code,5,7)) END service_point_full_code")
    .group('readings.id').order('billing_periods.period DESC,readings.reading_date DESC,readings.id DESC')
  }
  scope :by_service_point_full, -> s {
    joins(:billing_period, :reading_type, [meter: :meter_model])
    .joins('LEFT JOIN subscribers ON readings.subscriber_id=subscribers.id')
    .joins('LEFT JOIN (reading_incidences INNER JOIN reading_incidence_types ON reading_incidences.reading_incidence_type_id=reading_incidence_types.id) ON reading_incidences.reading_id=readings.id')
    .where('readings.subscriber_id = ?', s)
    .select("readings.id, readings.meter_id, readings.subscriber_id, readings.service_point_id, readings.reading_type_id,
             meters.meter_code, billing_periods.period, reading_types.name reading_type_name,
             readings.reading_date, readings.reading_index,
             GROUP_CONCAT(reading_incidence_types.code) reading_incidence_types_pluck, readings.reading_index_1,
             CASE ISNULL(readings.reading_index) OR ISNULL(readings.reading_index_1) WHEN TRUE THEN 0 ELSE (CASE WHEN readings.reading_index_1 <= readings.reading_index THEN readings.reading_index-readings.reading_index_1 ELSE ((POWER(10,meter_models.digits)-1)-readings.reading_index_1) + readings.reading_index END) END consumption_,
             readings.id reading_id, readings.bill_id, ISNULL(readings.bill_id) is_billable, readings.coefficient, readings.coefficient > 1 is_shared,
             CASE ISNULL(subscribers.subscriber_code) WHEN TRUE THEN '' ELSE CONCAT(SUBSTR(subscribers.subscriber_code,1,4),'-',SUBSTR(subscribers.subscriber_code,5,7)) END subscriber_full_code")
    .group('readings.id').order('billing_periods.period DESC,readings.reading_date DESC,readings.id DESC')
  }
  scope :by_meter_full, -> m {
    joins(:billing_period, :reading_type, [meter: :meter_model])
    .joins('LEFT JOIN service_points ON readings.service_point_id=service_points.id')
    .joins('LEFT JOIN subscribers ON readings.subscriber_id=subscribers.id')
    .joins('LEFT JOIN (reading_incidences INNER JOIN reading_incidence_types ON reading_incidences.reading_incidence_type_id=reading_incidence_types.id) ON reading_incidences.reading_id=readings.id')
    .where('readings.meter_id = ?', m)
    .select("readings.id, readings.meter_id, readings.subscriber_id, readings.service_point_id, readings.reading_type_id,
             meters.meter_code, billing_periods.period, reading_types.name reading_type_name,
             readings.reading_date, readings.reading_index,
             GROUP_CONCAT(reading_incidence_types.code) reading_incidence_types_pluck, readings.reading_index_1,
             CASE ISNULL(readings.reading_index) OR ISNULL(readings.reading_index_1) WHEN TRUE THEN 0 ELSE (CASE WHEN readings.reading_index_1 <= readings.reading_index THEN readings.reading_index-readings.reading_index_1 ELSE ((POWER(10,meter_models.digits)-1)-readings.reading_index_1) + readings.reading_index END) END consumption_,
             readings.id reading_id, readings.bill_id, ISNULL(readings.bill_id) is_billable, readings.coefficient, readings.coefficient > 1 is_shared,
             CASE ISNULL(service_points.code) WHEN TRUE THEN '' ELSE CONCAT(SUBSTR(service_points.code,1,4),'-',SUBSTR(service_points.code,5,7)) END service_point_full_code,
             CASE ISNULL(subscribers.subscriber_code) WHEN TRUE THEN '' ELSE CONCAT(SUBSTR(subscribers.subscriber_code,1,4),'-',SUBSTR(subscribers.subscriber_code,5,7)) END subscriber_full_code")
    .group('readings.id').order('billing_periods.period DESC,readings.reading_date DESC,readings.id DESC')
  }

  def to_label
    "#{reading_index} - #{reading_date.strftime("%d/%m/%Y %H:%M")}" if reading_date
  end

  def to_reading_date
    formatted_timestamp(reading_date) if reading_date
    # "#{reading_date.strftime("%d/%m/%Y %H:%M")}" if reading_date
  end

  def formatted_reading_date
    formatted_date(reading_date) rescue ''
  end

  def reading_days
    _d = 0
    if !reading_1.nil?
      if reading_date && reading_1.reading_date
        _d = ((reading_date.to_time - reading_1.reading_date.to_time)/86400).to_i
      end
    end
    _d
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

  # ************************************************
  # * WARNING! Do not use!                         *
  # ************************************************
  def dont_use_billable?
    # reading_type_id != 4 and (bill.nil? or !Invoice.where(original_invoice_id: bill.try(:invoices).try(:first).try(:id)).blank?)
    # bill.nil? or !Invoice.where(original_invoice_id: bill.try(:invoices).try(:first).try(:id)).blank?
    if bill.blank? && !subscriber.blank?
      Reading.where(subscriber_id: subscriber_id, billing_period_id: billing_period_id, reading_type_id: [ReadingType::NORMAL, ReadingType::OCTAVILLA, ReadingType::RETIRADA, ReadingType::AUTO]).select{|r| r.bill != nil}.blank?
    else
      false
    end
  end

  def billable?
    bill_id.nil?
  end

  def master_meter?
    meter.is_master?
  end

  def billable_and_master_meter?
    billable? && master_meter?
  end

  def is_shared?
    coefficient > 1
  end

  #
  # Consumption bqsed on Previous period reading
  # (billable consumption)
  #
  def consumption
    unless reading_index_1.nil? or reading_index.nil?
      if reading_index_1 <= reading_index
        reading_index - reading_index_1
      else
        # vuelta de contador
        (((10 ** meter.meter_model.digits)-1) - reading_index_1) + reading_index
      end
    else
      0
    end
  rescue
    0
  end

  #
  # Consumption bqsed on Previous chronological reading
  # (register consumption)
  #
  def previous_readings(meter=self.meter_id, subscriber=self.subscriber_id, service_point=self.service_point_id)
    w = ''
    w = "readings.meter_id = #{meter}" if !meter.nil?
    if w == ''
      w = "readings.subscriber_id = #{subscriber}" if !subscriber.nil?
    else
      w += " AND readings.subscriber_id = #{subscriber}" if !subscriber.nil?
    end
    if w == ''
      w = "readings.service_point_id = #{service_point}" if !service_point.nil?
    else
      w += " AND readings.service_point_id = #{service_point}" if !service_point.nil?
    end
    Reading.where("readings.id<>? AND readings.reading_date<=?", self.id, self.reading_date)
           .where(w).by_period_date
  end

  def previous_reading(meter=self.meter_id, subscriber=self.subscriber_id, service_point=self.service_point_id)
    pr = nil
    previous_readings = previous_readings(meter, subscriber, service_point)
    if !previous_readings.blank?
      # Are there readings with the same DATE and ID greater than the current one?
      pr_same_date = previous_readings.where("readings.reading_date = ? AND readings.id > ?", self.reading_date, self.id)
      if pr_same_date.blank?
        # First previous reading found
        pr = previous_readings.first
      else
        # Discard the same date readings found, and use the first valid one
        pr = previous_readings.where("readings.id NOT IN (?)", pr_same_date.pluck("readings.id")).first
      end
    end
    return pr
  end

  def registered_consumption(meter=self.meter_id, subscriber=self.subscriber_id, service_point=self.service_point_id)
    previous_reading = previous_reading(meter, subscriber, service_point)
    if (reading_index.nil? || previous_reading.nil?) || reading_type_id == ReadingType::INSTALACION
      0
    else
      (reading_index - previous_reading.reading_index) rescue 0
    end
  end

  # Tariff total amount of current reading (blocks + fixed)
  def price(tariff)
    aux = 0
    total = 0
    # Total by blocks
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

  # Sort by Id for Sunspot
  def sort_id
    self.id
  end

  #
  # Generates only one Prebill & associated invoices & items, based on current reading data
  #
  def generate_pre_bill(group_no=nil,user_id=nil,operation_id=1)
    pre_bill = nil
    if subscriber_billable?
      # cr = consumption_total_period             # consumption real
      cr = consumption_total_period_to_invoice  # consumption real to invoice
      ce = estimated_consumption(cr)            # consumption estimated
      co = 0                                    # consumption other
      cf = cr + ce + co                         # total consumption to invoice

      # Launch creation transaction
      pre_bill = create_pre_bill(group_no, user_id, operation_id, cr, ce, co, cf)
    end
    return pre_bill
  end

  ### DO NOT USE: It's a mess! ###
  def do_not_use_bills_with_this_attributes(operation_id=1)
    Bill.select{|b| b.bill_operation == operation_id and b.bill_period == billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == subscriber_id}.blank?
  end

  # It's right: Returns bills with this reading data
  def bills_with_this_attributes(operation_id=1)
    Bill.joins(:invoices).where(invoices: {invoice_operation_id: operation_id, billing_period_id: billing_period, invoice_type_id: InvoiceType::WATER}, subscriber_id: subscriber_id)
  end

  # It's right: Returns bills with this reading_id
  def bills
    Bill.where(reading_2_id: self.id)
  end

  #
  # Generates non-bulk individual bill/invoice
  #
  def generate_bill(next_bill_no=nil,user_id=nil,operation_id=1,payday_limit=nil,invoice_date=nil)
    @bill = nil
    if subscriber_billable? && bill_id.blank?     # This reading can be billed only if it's released (nil)
      # cr = consumption_total_period             # consumption real
      cr = consumption_total_period_to_invoice  # consumption real to invoice
      ce = estimated_consumption(cr)            # consumption estimated
      co = 0                                    # consumption other
      cf = cr + ce + co                         # total consumption to invoice

      # Bill No.
      if next_bill_no.nil?
        next_bill_no = bill_next_no(project)
        if next_bill_no == '$err'
          return nil
        end
      end

      # Launch transaction
      ActiveRecord::Base.transaction do
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

        subscriber.current_tariffs(reading_date).each do |tariffs_biller|
          @invoice = Invoice.create!(
            invoice_no: invoice_next_no(tariffs_biller[0], project.office_id),
            bill_id: @bill.id,
            invoice_status_id: InvoiceStatus::PENDING,
            invoice_type_id: InvoiceType::WATER,
            invoice_date: invoice_date,
            tariff_scheme_id: nil,
            payday_limit: payday_limit.blank? ? invoice_date : payday_limit,
            invoice_operation_id: operation_id,
            billing_period_id: billing_period_id,
            consumption: cf,
            consumption_real: cr,
            consumption_estimated: ce,
            consumption_other: co,
            biller_id: tariffs_biller[0],
            discount_pct: 0.0,
            exemption: 0.0,
            charge_account_id: ChargeAccount.incomes(project_id).first.id,
            created_by: user_id,
            reading_1_date: reading_1.try(:reading_date),
            reading_2_date: reading_date,
            reading_1_index: reading_1.try(:reading_index),
            reading_2_index: reading_index,
            organization_id: project.organization_id )

          tariffs_biller[1].each do |tariff|    # tariff: current tariff for current reading
            # Computes & generates Invoice Items
            generate_invoice_items(tariff, @invoice, @bill, cf, user_id)
          end # tariffs_biller[1].each do |tariff|

          # Save totals in generated invoice
          _i = Invoice.find(@invoice.id)
          _i.totals = _i.total
          _i.save
        end # subscriber.current_tariffs(reading_date).each
      end # end transaction
      # Update estimated consumption if necessary
      update_current_estimation_balance(ce, user_id)
      # Save generated bill_id in current reading
      self.bill_id = @bill.id
      self.save
    end # !subscriber.blank? && bill_id.blank?
    return @bill

  rescue ActiveRecord::RecordInvalid
    puts I18n.t(:transaction_error, var: "generate_bill")
  end

  #
  # Subscriber billable?
  #
  def subscriber_billable?
    r = false
    begin
      if !subscriber.blank? # Subscriber present
        if subscriber.activated?  # Subscriber active
          if subscriber.starting_at < billing_period.billing_ending_date
            r = true
          end
        end
      end
    rescue
      r = false
    end
    return r
  end

  #
  # Real consumption to invoice (by period)
  #
  def consumption_total_period_to_invoice
    ctp = consumption_total_period
    meter.is_shared? ? (ctp / meter.shared_coefficient).round : ctp
  end

  #
  # Real consumption (by period)
  #
  def consumption_total_period
    # @readings = Reading.where(billing_period_id: billing_period_id, subscriber_id: subscriber_ids).where('reading_type_id NOT IN (?)',[1,2,5,6]).group_by(&:reading_1_id)
    readings = subscriber.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    total = 0
    ccm = 0
    readings.each do |reading|
      total += reading[1].last.consumption
    end
    if meter.is_master?
      # Billable Master Meter:
      # Consumption to bill must be the substraction between this consumption
      # and the sum of the child meters consumption
      ccm = consumption_child_meters
      total = ccm > total ? 0 : total - ccm
    end
    return total
  end

  #
  # Child meters real consumption
  #
  def consumption_child_meters
    total = 0
    meter.child_meters.each do |c|
      readings = c.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
      readings.each do |reading|
        total += reading[1].last.consumption
      end
    end
    return total
  end

  #
  # Estimated consumption
  #
  # If CR is zero
  def estimated_consumption(cr)
    total = 0
    # If real consumption equals zero, try to estimate
    if cr == 0
      # Only estimates if there is an incidence that requires estimating
      if ReadingIncidence.reading_should_be_estimated(self.id)
        # 1. Consumption invoiced in the same period of last year (reading_2)
        total = consumption_invoiced(reading_2)
        if total == 0
          # 2. Consumption invoiced in the last period (reading_1)
          total = consumption_invoiced(reading_1)
          if total == 0
            # 3. Average consumption of...
            invoice_date = billing_period.try(:prebilling_starting_date) || Date.today
            # 3.1. ...the last 36 months of reading
            from_date = invoice_date - 36.months
            total = consumption_previous_readings(from_date, invoice_date)
            if total == 0
              # 3.2. ...the last 12 months of reading
              from_date = invoice_date - 12.months
              total = consumption_previous_readings(from_date, invoice_date)
              if total == 0
                # 4. Nominal capacity of the meter x 15 hs x quantity of months
                nominal_flow = meter.caliber.nominal_flow rescue 1.5
                nominal_flow = 1.5 if nominal_flow.blank?
                total = (nominal_flow * 15) * billing_frequency.total_months
              end # 3.2
            end # 3.1
          end # 2
        end # 1
      end # ReadingIncidence.reading_should_be_estimated(self.id)
    else # If real consumption not equals zero, try to compensate
      total = estimated_consumption_with_cr(cr)
    end # cr == 0
    total || 0
  end

  # Previous average readed consumption
  def consumption_previous_readings(from_date, to_date)
    begin
      previous_readings = subscriber.readings.where('reading_date between ? AND ?', from_date, to_date).select('SUM(reading_index - reading_index_1) CONSUMPTION,COUNT(*) COUNTER')
      (previous_readings[0].CONSUMPTION / previous_readings[0].COUNTER).round
    rescue
      0
    end
  end

  # Previous invoiced consumption
  def consumption_invoiced(previous_reading)
    begin
      previous_consumption = previous_reading.bill.active_supply_invoices.joins(:invoice).select('SUM(consumption) CONSUMPTION')
      (previous_consumption[0].CONSUMPTION).round
    rescue
      0
    end
  end

  # If CR is greater than zero
  def estimated_consumption_with_cr(cr)
    total = 0
    # if real consumption greater than zero, must compensate estimation balance
    if cr > 0
      total = cr < current_estimation_balance ? cr * (-1) : current_estimation_balance * (-1)
    end # cr > 0
    total || 0
  end

  # Update estimated consumption
  def update_current_estimation_balance(ce, user_id)
    if ce != 0
      subscriber_current_estimation = subscriber.current_estimation
      if subscriber_current_estimation.nil?
        # There is not a current estimation: Create new
        SubscriberEstimationBalance.create!(subscriber_id: subscriber_id, estimation_balance: ce,
                                            estimation_init_at: Time.now, estimation_reset_at: nil,
                                            created_by: user_id)
      else
        # There is an active estimation: Update it
        subscriber_current_estimation.estimation_balance += ce
        subscriber_current_estimation.estimation_reset_at = Time.now if subscriber_current_estimation.estimation_balance == 0
        subscriber_current_estimation.save
      end
    end
  end

  # Current estimation balance
  def current_estimation_balance
    subscriber.current_estimation_balance
  end

  #
  # Preinvoice & Invoice Items creation
  #
  # Creates Preinvoice Item
  def create_pre_invoice_item(tariff, pre_invoice_id, subcode, price, quantity, measure, tax_type_id, discount_pct, user_id, d)
    PreInvoiceItem.create(
      pre_invoice_id: pre_invoice_id,
      code: tariff.try(:billable_item).try(:billable_concept).try(:code),
      description: d + tariff.try(:billable_item).try(:billable_concept).try(:name),
      tariff_id: tariff.id,
      price: price,
      quantity: quantity,
      tax_type_id: tax_type_id,
      discount_pct: discount_pct,
      discount: 0.0,
      product_id: nil,
      subcode: subcode,
      measure_id: measure,
      created_by: user_id)
  end

  # Create Preinvoice Items, for current tariff
  def save_pre_invoice_items(tariff, pre_invoice, pre_bill, cf, user_id)
    # Fixed
    if !tariff.fixed_fee.zero?
      tariff_code = tariff.try(:billable_item).try(:billable_concept).try(:code) rescue ''
      # tariff_price = tariff.fixed_fee / tariff.billing_frequency.total_months
      tariff_price = (tariff.fixed_fee / tariff.billing_frequency.total_months) * coefficient_by_users(tariff, 'F')
      if tariff_code == 'SUM' && should_bill_by_inhabitants_or_endowments?(tariff, 'F')
        tariff_price = tariff_price * subscriber.right_inhabitants_and_endowments
      end
      if tariff_code == 'DEP'
        tariff_price = tariff_price * subscriber.right_equiv_dwelling
      end
      create_pre_invoice_item(tariff,
                              pre_invoice.id,
                              "CF",
                              tariff_price,
                              billing_frequency.total_months,
                              tariff.billing_frequency.fix_measure_id,
                              tariff.try(:tax_type_f_id),
                              tariff.try(:discount_pct_f),
                              user_id, '')
    elsif tariff.percentage_fixed_fee > 0 and !tariff.percentage_applicable_formula.blank?
      create_pre_invoice_item(tariff,
                              pre_invoice.id,
                              "CF",
                              ((tariff.percentage_fixed_fee / 100) * PreInvoice.find(pre_invoice.id).total_by_concept_ff(tariff.percentage_applicable_formula)) / billing_frequency.total_months,
                              billing_frequency.total_months,
                              tariff.billing_frequency.fix_measure_id,
                              tariff.try(:tax_type_f_id),
                              tariff.try(:discount_pct_f),
                              user_id, '')
    end

    # Variables
    # block_frequency = billing_frequency.total_months.to_d / tariff.billing_frequency.total_months.to_d
    block_frequency = coefficient_for_billing_blocks(tariff)
    if !tariff.block1_limit.nil? && tariff.block1_limit > 0
      #+++ Blocks +++
      limit_before = 0
      block_limit = 0
      (1..8).each do |i|
        block_limit = ((tariff.instance_eval("block#{i}_limit") + coefficient_by_inhabitants(tariff, 'V')) * block_frequency * coefficient_by_users(tariff, 'V')).round rescue nil
        # if limit nil (last block) or limit > consumption
        if block_limit.nil? || block_limit >= (cf || 0)
          create_pre_invoice_item(tariff,
                                  pre_invoice.id,
                                  "BL"+i.to_s,
                                  tariff.instance_eval("block#{i}_fee"),
                                  ((cf || 0) - limit_before),
                                  tariff.billing_frequency.var_measure_id,
                                  tariff.try(:tax_type_b_id),
                                  tariff.try(:discount_pct_b),
                                  user_id, '')
          break
        else
          create_pre_invoice_item(tariff,
                                  pre_invoice.id,
                                  "BL"+i.to_s,
                                  tariff.instance_eval("block#{i}_fee"),
                                  block_limit - limit_before,
                                  tariff.billing_frequency.var_measure_id,
                                  tariff.try(:tax_type_b_id),
                                  tariff.try(:discount_pct_b),
                                  user_id, '')
          limit_before = block_limit
        end
      end # (1..8).each
    elsif tariff.percentage_fee > 0 and !tariff.percentage_applicable_formula.blank?
      #+++ Percentage +++
      create_pre_invoice_item(tariff,
                              pre_invoice.id,
                              "VP",
                              cf != 0.0 ? (tariff.percentage_fee/100) * PreInvoice.find(pre_invoice.id).total_by_concept(tariff.percentage_applicable_formula, false) / cf : 0.0,
                              cf,
                              tariff.billing_frequency.var_measure_id,
                              tariff.try(:tax_type_p_id),
                              tariff.try(:discount_pct_p),
                              user_id, '')
    elsif tariff.variable_fee > 0
      #+++ Variable (like one-block tariff) +++
      create_pre_invoice_item(tariff,
                              pre_invoice.id,
                              "CV",
                              tariff.variable_fee,
                              cf,
                              tariff.billing_frequency.var_measure_id,
                              tariff.try(:tax_type_v_id),
                              tariff.try(:discount_pct_v),
                              user_id, '')
    end # tariff.block1_limit > 0
  end

  # Creates Invoice Item
  def create_invoice_item(tariff, invoice_id, subcode, price, quantity, measure, tax_type_id, discount_pct, user_id, d)
    InvoiceItem.create(
      invoice_id: invoice_id,
      code: tariff.try(:billable_item).try(:billable_concept).try(:code),
      description: d + tariff.try(:billable_item).try(:billable_concept).try(:name),
      tariff_id: tariff.id,
      price: price,
      quantity: quantity,
      tax_type_id: tax_type_id,
      discount_pct: discount_pct,
      discount: 0.0,
      product_id: nil,
      subcode: subcode,
      measure_id: measure,
      created_by: user_id)
  end

  # Create Invoice Items, for current tariff
  def save_invoice_items(tariff, invoice, bill, cf, user_id)
    # Fixed
    if !tariff.fixed_fee.zero?
      tariff_code = tariff.try(:billable_item).try(:billable_concept).try(:code) rescue ''
      # tariff_price = tariff.fixed_fee / tariff.billing_frequency.total_months
      tariff_price = (tariff.fixed_fee / tariff.billing_frequency.total_months) * coefficient_by_users(tariff, 'F')
      if tariff_code == 'SUM' && should_bill_by_inhabitants_or_endowments?(tariff, 'F')
        tariff_price = tariff_price * subscriber.right_inhabitants_and_endowments
      end
      if tariff_code == 'DEP'
        tariff_price = tariff_price * subscriber.right_equiv_dwelling
      end
      create_invoice_item(tariff,
                          invoice.id,
                          "CF",
                          tariff_price,
                          billing_frequency.total_months,
                          tariff.billing_frequency.fix_measure_id,
                          tariff.try(:tax_type_f_id),
                          tariff.try(:discount_pct_f),
                          user_id, '')
    elsif tariff.percentage_fixed_fee > 0 and !tariff.percentage_applicable_formula.blank?
      create_invoice_item(tariff,
                          invoice.id,
                          "CF",
                          ((tariff.percentage_fixed_fee/100) * Invoice.find(invoice.id).total_by_concept_ff(tariff.percentage_applicable_formula))  / billing_frequency.total_months,
                          billing_frequency.total_months,
                          tariff.billing_frequency.fix_measure_id,
                          tariff.try(:tax_type_f_id),
                          tariff.try(:discount_pct_f),
                          user_id, '')
    end

    # Variables
    # block_frequency = billing_frequency.total_months.to_d / tariff.billing_frequency.total_months.to_d
    block_frequency = coefficient_for_billing_blocks(tariff)
    if !tariff.block1_limit.nil? && tariff.block1_limit > 0
      limit_before = 0
      block_limit = 0
      (1..8).each do |i|
        block_limit = ((tariff.instance_eval("block#{i}_limit") + coefficient_by_inhabitants(tariff, 'V')) * block_frequency * coefficient_by_users(tariff, 'V')).round rescue nil
        # if limit nil (last block) or limit > consumption
        if block_limit.nil? || block_limit >= (cf || 0)
          create_invoice_item(tariff,
                              invoice.id,
                              "BL"+i.to_s,
                              tariff.instance_eval("block#{i}_fee"),
                              ((cf || 0) - limit_before),
                              tariff.billing_frequency.var_measure_id,
                              tariff.try(:tax_type_b_id),
                              tariff.try(:discount_pct_b),
                              user_id, '')
          break
        else
          create_invoice_item(tariff,
                              invoice.id,
                              "BL"+i.to_s,
                              tariff.instance_eval("block#{i}_fee"),
                              block_limit - limit_before,
                              tariff.billing_frequency.var_measure_id,
                              tariff.try(:tax_type_b_id),
                              tariff.try(:discount_pct_b),
                              user_id, '')
          limit_before = block_limit
        end
      end # (1..8).each
    elsif tariff.percentage_fee > 0 and !tariff.percentage_applicable_formula.blank?
      create_invoice_item(tariff,
                          invoice.id,
                          "VP",
                          cf != 0.0 ? (tariff.percentage_fee/100) * Invoice.find(invoice.id).total_by_concept(tariff.percentage_applicable_formula, false) / cf : 0.0,
                          cf,
                          tariff.billing_frequency.var_measure_id,
                          tariff.try(:tax_type_p_id),
                          tariff.try(:discount_pct_p),
                          user_id, '')
    elsif tariff.variable_fee > 0
      create_invoice_item(tariff,
                          invoice.id,
                          "CV",
                          tariff.variable_fee,
                          cf,
                          tariff.billing_frequency.var_measure_id,
                          tariff.try(:tax_type_v_id),
                          tariff.try(:discount_pct_v),
                          user_id, '')
    end # tariff.block1_limit > 0
  end

  #
  # Apply tariffs & Generate respective items
  #
  # Computes & generates Preinvoice Items
  # tariff: current tariff for current reading
  def generate_pre_invoice_items(tariff, pre_invoice, pre_bill, cf, user_id)
    # Should prorate
    should_prorate, prev_reading_tariff = should_prorate?(tariff)
    if should_prorate
      # Must prorate
      prorate_consumption_and_apply_tariffs('P', tariff, prev_reading_tariff, pre_invoice, pre_bill, cf, user_id)
    else
      # Current tariff only
      save_pre_invoice_items(tariff, pre_invoice, pre_bill, cf, user_id)
    end # should_prorate
  end

  # Computes & generates Invoice Items
  # tariff: current tariff for current reading
  def generate_invoice_items(tariff, invoice, bill, cf, user_id)
    # Should prorate
    should_prorate, prev_reading_tariff = should_prorate?(tariff)
    if should_prorate
      # Must prorate
      prorate_consumption_and_apply_tariffs('I', tariff, prev_reading_tariff, invoice, bill, cf, user_id)
    else
      # Current tariff only
      save_invoice_items(tariff, invoice, bill, cf, user_id)
    end # should_prorate
  end

  #
  # Seasonal Rates:
  # Open Billing Blocks
  #
  # Calculate coefficient for variable fee by blocks.
  def coefficient_for_billing_blocks(tariff)
    # Should be applied to block_limits
    mm = months_between_last_normal_reading_and_current_reading
    mm > 0 ? (mm / tariff.billing_frequency.total_months).round : billing_frequency.total_months.to_d / tariff.billing_frequency.total_months.to_d
  end

  # Calculate months between readings
  def months_between_last_normal_reading_and_current_reading
    # If current reading type is NORMAL
    # and the previous year reading type is NORMAL
    # and the intermediate readings are AUTO or do not exist
    # must obtain the difference in months to apply
    mm = 0
    if !reading_2.nil? && (reading_type_id == ReadingType::NORMAL && reading_2.reading_type_id == ReadingType::NORMAL)
      intermediate = subscriber.readings.where('(readings.id > ? AND readings.id < ?) AND reading_type_id IN (?)',reading_2.id,id,[ReadingType::INSTALACION,ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA]).group(:reading_type_id).select('reading_type_id,count(*) AS COUNTER')
      if intermediate.blank?  # No NORMAL intermediate readings, obtain months
         mm = ((reading_date.to_date - reading_2.reading_date.to_date).to_i / 30.436875).round
      end
    end
    mm
  end

  #
  # Rates by Inhabitants or Endowments or Users
  #
  def coefficient_by_inhabitants(tariff, fee_type)
    # Should be used to add to block limits
    if should_bill_by_inhabitants?(tariff, fee_type) && subscriber.inhabitants > tariff.inhabitants_from
      (subscriber.inhabitants - tariff.inhabitants_from) * tariff.inhabitants_increment rescue 0
    else
      0
    end
  end

  def coefficient_by_endowments(tariff, fee_type)
    if should_bill_by_endowments?(tariff, fee_type) && subscriber.endowments > tariff.endowments_from
      (subscriber.endowments - tariff.endowments_from) * tariff.endowments_increment rescue 0
    else
      0
    end
  end

  def coefficient_by_users(tariff, fee_type)
    # Should be used to multiply to block limits and fixed fee price
    should_bill_by_users?(tariff, fee_type) ? subscriber.meter_users : 1
  end

  def should_bill_by_inhabitants?(tariff, fee_type)
    tariff.billable_item.bill_by_inhabitants && ((tariff.inhabitants_increment_apply_to == Tariff::BOTH) ||
    ((fee_type = 'F' && tariff.inhabitants_increment_apply_to == Tariff::FIXED) ||
     (fee_type = 'V' && tariff.inhabitants_increment_apply_to == Tariff::VARIABLE)))
  end

  def should_bill_by_endowments?(tariff, fee_type)
    tariff.billable_item.bill_by_endowments && ((tariff.endowments_increment_apply_to == Tariff::BOTH) ||
    ((fee_type = 'F' && tariff.endowments_increment_apply_to == Tariff::FIXED) ||
     (fee_type = 'V' && tariff.endowments_increment_apply_to == Tariff::VARIABLE)))
  end

  def should_bill_by_inhabitants_or_endowments?(tariff, fee_type)
    should_bill_by_inhabitants?(tariff, fee_type) || should_bill_by_endowments?(tariff, fee_type)
  end

  def should_bill_by_inhabitants_and_endowments?(tariff, fee_type)
    should_bill_by_inhabitants?(tariff, fee_type) && should_bill_by_endowments?(tariff, fee_type)
  end

  def should_bill_by_users?(tariff, fee_type)
    tariff.billable_item.bill_by_users && ((tariff.users_increment_apply_to == Tariff::BOTH) ||
    ((fee_type = 'F' && tariff.users_increment_apply_to == Tariff::FIXED) ||
     (fee_type = 'V' && tariff.users_increment_apply_to == Tariff::VARIABLE)))
  end

  #
  # Proration
  #
  # Should prorate?
  def should_prorate?(tariff)
    ret = false
    prev_reading_tariff = nil
    # Is there previous reading?
    if !reading_1_id.blank?
      # Previous reading exists: Search tariff for previous reading
      prev_reading_tariff = search_tariff_to_apply(reading_1.reading_date,
                                                   tariff.billable_item.billable_concept_id,
                                                   tariff.tariff_type_id,
                                                   tariff.caliber_id)
      if (!prev_reading_tariff.nil?) && (tariff.id != prev_reading_tariff.tariff_id)
        # Must prorate
        ret = true
      end
    end
    return ret, prev_reading_tariff
  end

  # Send to save new prorated item
  def prorate_create_item(t, tariff, invoice_id, subcode, price, quantity, measure, tax_type_id, discount_pct, user_id, d)
    if t == 'P'
      create_pre_invoice_item(tariff, invoice_id, subcode, price, quantity, measure, tax_type_id, discount_pct, user_id, d)
    else
      create_invoice_item(tariff, invoice_id, subcode, price, quantity, measure, tax_type_id, discount_pct, user_id, d)
    end
  end

  # Prorated consumption
  def prorate_consumption_and_apply_tariffs(t, tariff, prev_reading_tariff, pre_invoice, pre_bill, cf, user_id)
    # Calculates days
    days_between_readings = (reading_date.to_date - reading_1.reading_date.to_date).to_i
    days_current_tariff = (reading_date.to_date - tariff.starting_at.to_date).to_i + 1
    days_previous_tariff = days_between_readings - days_current_tariff
    # days_previous_tariff = (prev_reading_tariff.ending_at - reading_1.reading_date).to_i
    days_billing_period = (billing_period.billing_ending_date.to_date - billing_period.billing_starting_date.to_date).to_i rescue 0
    days_current_period = (billing_period.billing_ending_date.to_date - tariff.starting_at.to_date).to_i rescue 0
    days_previous_period = days_billing_period - days_current_period rescue 0

    # Calculates coefficients
    variable_current_coefficient = days_current_tariff.to_d / days_between_readings.to_d
    variable_previous_coefficient = days_previous_tariff.to_d / days_between_readings.to_d
    if days_billing_period == 0
      fixed_current_coefficient = variable_current_coefficient
      fixed_previous_coefficient = variable_previous_coefficient
    else
      fixed_current_coefficient = days_current_period.to_d / days_billing_period.to_d
      fixed_previous_coefficient = days_previous_period.to_d / days_billing_period.to_d
    end

    #####################
    ### Apply Tariffs ###
    #####################

    prev_reading_subscriber_tariff_tariff = prev_reading_tariff.tariff

    #+++ Fixed +++
    previous_fixed_fee_qty = (billing_frequency.total_months * fixed_previous_coefficient).round
    current_fixed_fee_qty = billing_frequency.total_months - previous_fixed_fee_qty
    tariff_code = ''
    tariff_price = 0
    # Previous
    if previous_fixed_fee_qty > 0
      if !prev_reading_subscriber_tariff_tariff.fixed_fee.zero?
        tariff_code = prev_reading_subscriber_tariff_tariff.try(:billable_item).try(:billable_concept).try(:code) rescue ''
        tariff_price = (prev_reading_subscriber_tariff_tariff.fixed_fee / prev_reading_subscriber_tariff_tariff.billing_frequency.total_months) * coefficient_by_users(prev_reading_subscriber_tariff_tariff, 'F')
        if tariff_code == 'SUM' && should_bill_by_inhabitants_or_endowments?(prev_reading_subscriber_tariff_tariff, 'F')
          tariff_price = tariff_price * subscriber.right_inhabitants_and_endowments
        end
        if tariff_code == 'DEP'
          tariff_price = tariff_price * subscriber.right_equiv_dwelling
        end
        prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                            pre_invoice.id,
                            "CF",
                            tariff_price,
                            previous_fixed_fee_qty,
                            prev_reading_subscriber_tariff_tariff.billing_frequency.fix_measure_id,
                            prev_reading_subscriber_tariff_tariff.try(:tax_type_f_id),
                            prev_reading_subscriber_tariff_tariff.try(:discount_pct_f),
                            user_id, '0')
      elsif prev_reading_subscriber_tariff_tariff.percentage_fixed_fee > 0 and !prev_reading_subscriber_tariff_tariff.percentage_applicable_formula.blank?
        if t == 'P'
          prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                              pre_invoice.id,
                              "CF",
                              ((prev_reading_subscriber_tariff_tariff.percentage_fixed_fee/100) * PreInvoice.find(pre_invoice.id).total_by_concept_ff(prev_reading_subscriber_tariff_tariff.percentage_applicable_formula)) / billing_frequency.total_months,
                              previous_fixed_fee_qty,
                              prev_reading_subscriber_tariff_tariff.billing_frequency.fix_measure_id,
                              prev_reading_subscriber_tariff_tariff.try(:tax_type_f_id),
                              prev_reading_subscriber_tariff_tariff.try(:discount_pct_f),
                              user_id, '0')
        else
          prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                              pre_invoice.id,
                              "CF",
                              ((prev_reading_subscriber_tariff_tariff.percentage_fixed_fee/100) * Invoice.find(pre_invoice.id).total_by_concept_ff(prev_reading_subscriber_tariff_tariff.percentage_applicable_formula)) / billing_frequency.total_months,
                              previous_var_fee_qty,
                              prev_reading_subscriber_tariff_tariff.billing_frequency.fix_measure_id,
                              prev_reading_subscriber_tariff_tariff.try(:tax_type_f_id),
                              prev_reading_subscriber_tariff_tariff.try(:discount_pct_f),
                              user_id, '0')
        end
      end
    end
    # Current
    if current_fixed_fee_qty > 0
      if !tariff.fixed_fee.zero?
        tariff_code = tariff.try(:billable_item).try(:billable_concept).try(:code) rescue ''
        tariff_price = (tariff.fixed_fee / tariff.billing_frequency.total_months) * coefficient_by_users(tariff, 'F')
        if tariff_code == 'SUM' && should_bill_by_inhabitants_or_endowments?(tariff, 'F')
          tariff_price = tariff_price * subscriber.right_inhabitants_and_endowments
        end
        if tariff_code == 'DEP'
          tariff_price = tariff_price * subscriber.right_equiv_dwelling
        end
        prorate_create_item(t, tariff,
                            pre_invoice.id,
                            "CF",
                            tariff_price,
                            current_fixed_fee_qty,
                            tariff.billing_frequency.fix_measure_id,
                            tariff.try(:tax_type_f_id),
                            tariff.try(:discount_pct_f),
                            user_id, '1')
      elsif tariff.percentage_fixed_fee > 0 and !tariff.percentage_applicable_formula.blank?
        if t == 'P'
          prorate_create_item(t, tariff,
                              pre_invoice.id,
                              "CF",
                              ((tariff.percentage_fixed_fee/100) * PreInvoice.find(pre_invoice.id).total_by_concept_ff(tariff.percentage_applicable_formula)) / billing_frequency.total_months,
                              current_fixed_fee_qty,
                              tariff.billing_frequency.fix_measure_id,
                              tariff.try(:tax_type_f_id),
                              tariff.try(:discount_pct_f),
                              user_id, '0')
        else
          prorate_create_item(t, tariff,
                              pre_invoice.id,
                              "CF",
                              ((tariff.percentage_fixed_fee/100) * Invoice.find(pre_invoice.id).total_by_concept_ff(tariff.percentage_applicable_formula)) / billing_frequency.total_months,
                              current_fixed_fee_qty,
                              tariff.billing_frequency.fix_measure_id,
                              tariff.try(:tax_type_f_id),
                              tariff.try(:discount_pct_f),
                              user_id, '0')
        end
      end
    end

    #+++ Blocks +++
    # Previous
    block_fee_qty = 0
    # block_frequency = billing_frequency.total_months.to_d / prev_reading_subscriber_tariff_tariff.billing_frequency.total_months.to_d
    block_frequency = coefficient_for_billing_blocks(prev_reading_subscriber_tariff_tariff)
    previous_block_fee_quantities = []
    if !prev_reading_subscriber_tariff_tariff.block1_limit.nil? && prev_reading_subscriber_tariff_tariff.block1_limit > 0
      limit_before = 0
      block_limit = 0
      (1..8).each do |i|
        # block_limit = (prev_reading_subscriber_tariff_tariff.instance_eval("block#{i}_limit") * block_frequency).round rescue nil
        block_limit = ((prev_reading_subscriber_tariff_tariff.instance_eval("block#{i}_limit") + coefficient_by_inhabitants(prev_reading_subscriber_tariff_tariff, 'V')) * block_frequency * coefficient_by_users(prev_reading_subscriber_tariff_tariff, 'V')).round rescue nil
        if block_limit.nil? || block_limit >= (cf || 0)
          block_fee_qty = (((cf || 0) - limit_before) * variable_previous_coefficient).round
          prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                              pre_invoice.id,
                              "BL"+i.to_s,
                              prev_reading_subscriber_tariff_tariff.instance_eval("block#{i}_fee"),
                              block_fee_qty,
                              prev_reading_subscriber_tariff_tariff.billing_frequency.var_measure_id,
                              prev_reading_subscriber_tariff_tariff.try(:tax_type_b_id),
                              prev_reading_subscriber_tariff_tariff.try(:discount_pct_b),
                              user_id, '0')
          previous_block_fee_quantities = previous_block_fee_quantities << [(((cf || 0) - limit_before) * variable_previous_coefficient), block_fee_qty]
          break
        else
          block_fee_qty = ((block_limit - limit_before) * variable_previous_coefficient).round
        end
        prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                            pre_invoice.id,
                            "BL"+i.to_s,
                            prev_reading_subscriber_tariff_tariff.instance_eval("block#{i}_fee"),
                            block_fee_qty,
                            prev_reading_subscriber_tariff_tariff.billing_frequency.var_measure_id,
                            prev_reading_subscriber_tariff_tariff.try(:tax_type_b_id),
                            prev_reading_subscriber_tariff_tariff.try(:discount_pct_b),
                            user_id, '0')
        previous_block_fee_quantities = previous_block_fee_quantities << [((block_limit - limit_before) * variable_previous_coefficient), block_fee_qty]
        limit_before = block_limit
      end # (1..8).each
    end
    # Current
    block_fee_qty = 0
    # block_frequency = billing_frequency.total_months.to_d / tariff.billing_frequency.total_months.to_d
    block_frequency = coefficient_for_billing_blocks(tariff)
    if !tariff.block1_limit.nil? && tariff.block1_limit > 0
      limit_before = 0
      block_limit = 0
      (1..8).each do |i|
        # block_limit = (tariff.instance_eval("block#{i}_limit") * block_frequency).round rescue nil
        block_limit = ((tariff.instance_eval("block#{i}_limit") + coefficient_by_inhabitants(tariff, 'V')) * block_frequency * coefficient_by_users(tariff, 'V')).round rescue nil
        if block_limit.nil? || block_limit >= (cf || 0)
          if previous_block_fee_quantities[i-1].nil?
            block_fee_qty = (((cf || 0) - limit_before) * variable_current_coefficient).round
          else
            block_fee_qty = ((previous_block_fee_quantities[i-1][0] - previous_block_fee_quantities[i-1][1]) +
                            (((cf || 0) - limit_before) * variable_current_coefficient)).round
          end
          prorate_create_item(t, tariff,
                              pre_invoice.id,
                              "BL"+i.to_s,
                              tariff.instance_eval("block#{i}_fee"),
                              block_fee_qty,
                              tariff.billing_frequency.var_measure_id,
                              tariff.try(:tax_type_b_id),
                              tariff.try(:discount_pct_b),
                              user_id, '1')
          break
        else
          if previous_block_fee_quantities[i-1].nil?
            block_fee_qty = ((block_limit - limit_before) * variable_current_coefficient).round
          else
            block_fee_qty = ((previous_block_fee_quantities[i-1][0] - previous_block_fee_quantities[i-1][1]) +
                            ((block_limit - limit_before) * variable_current_coefficient)).round
          end
        end
        prorate_create_item(t, tariff,
                            pre_invoice.id,
                            "BL"+i.to_s,
                            tariff.instance_eval("block#{i}_fee"),
                            block_fee_qty,
                            tariff.billing_frequency.var_measure_id,
                            tariff.try(:tax_type_b_id),
                            tariff.try(:discount_pct_b),
                            user_id, '1')
        limit_before = block_limit
      end # (1..8).each
    end

    #+++ Variables +++
    previous_var_fee_qty = (cf * variable_previous_coefficient).round
    current_var_fee_qty = cf - previous_var_fee_qty

    #+++ Percentage +++
    # Previous
    if prev_reading_subscriber_tariff_tariff.percentage_fee > 0 and !prev_reading_subscriber_tariff_tariff.percentage_applicable_formula.blank?
      if t == 'P'
        prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                            pre_invoice.id,
                            "VP",
                            cf != 0.0 ? (prev_reading_subscriber_tariff_tariff.percentage_fee/100) * PreInvoice.find(pre_invoice.id).total_by_concept(prev_reading_subscriber_tariff_tariff.percentage_applicable_formula, false) / cf : 0.0,
                            previous_var_fee_qty,
                            prev_reading_subscriber_tariff_tariff.billing_frequency.var_measure_id,
                            prev_reading_subscriber_tariff_tariff.try(:tax_type_p_id),
                            prev_reading_subscriber_tariff_tariff.try(:discount_pct_p),
                            user_id, '0')
      else
        prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                            pre_invoice.id,
                            "VP",
                            cf != 0.0 ? (prev_reading_subscriber_tariff_tariff.percentage_fee/100) * Invoice.find(pre_invoice.id).total_by_concept(prev_reading_subscriber_tariff_tariff.percentage_applicable_formula, false) / cf : 0.0,
                            previous_var_fee_qty,
                            prev_reading_subscriber_tariff_tariff.billing_frequency.var_measure_id,
                            prev_reading_subscriber_tariff_tariff.try(:tax_type_p_id),
                            prev_reading_subscriber_tariff_tariff.try(:discount_pct_p),
                            user_id, '0')
      end
    end
    # Current
    if tariff.percentage_fee > 0 and !tariff.percentage_applicable_formula.blank?
      if t == 'P'
        prorate_create_item(t, tariff,
                            pre_invoice.id,
                            "VP",
                            cf != 0.0 ? (tariff.percentage_fee/100) * PreInvoice.find(pre_invoice.id).total_by_concept(tariff.percentage_applicable_formula, false) / cf : 0.0,
                            current_var_fee_qty,
                            tariff.billing_frequency.var_measure_id,
                            tariff.try(:tax_type_p_id),
                            tariff.try(:discount_pct_p),
                            user_id, '1')
      else
        prorate_create_item(t, tariff,
                            pre_invoice.id,
                            "VP",
                            cf != 0.0 ? (tariff.percentage_fee/100) * Invoice.find(pre_invoice.id).total_by_concept(tariff.percentage_applicable_formula, false) / cf : 0.0,
                            current_var_fee_qty,
                            tariff.billing_frequency.var_measure_id,
                            tariff.try(:tax_type_p_id),
                            tariff.try(:discount_pct_p),
                            user_id, '1')
      end
    end

    #+++ Variable +++
    # Previous
    if prev_reading_subscriber_tariff_tariff.variable_fee > 0
      prorate_create_item(t, prev_reading_subscriber_tariff_tariff,
                          pre_invoice.id,
                          "CV",
                          prev_reading_subscriber_tariff_tariff.variable_fee,
                          previous_var_fee_qty,
                          prev_reading_subscriber_tariff_tariff.billing_frequency.var_measure_id,
                          prev_reading_subscriber_tariff_tariff.try(:tax_type_v_id),
                          prev_reading_subscriber_tariff_tariff.try(:discount_pct_v),
                          user_id, '0')
    end
    # Current
    if tariff.variable_fee > 0
      prorate_create_item(t, tariff,
                          pre_invoice.id,
                          "CV",
                          tariff.variable_fee,
                          current_var_fee_qty,
                          tariff.billing_frequency.var_measure_id,
                          tariff.try(:tax_type_v_id),
                          tariff.try(:discount_pct_v),
                          user_id, '1')
    end
  end # prorate_consumption_and_apply_tariffs

  # Search tariffs (normally, for prorates previous reading)
  def search_tariff_to_apply(_date, _concept, _type, _caliber=nil)
    if _caliber.nil?
      self.subscriber.subscriber_tariffs.joins(tariff: :billable_item)
                      .where('(? BETWEEN subscriber_tariffs.starting_at AND subscriber_tariffs.ending_at) OR (? >= subscriber_tariffs.starting_at AND subscriber_tariffs.ending_at IS NULL)', _date, _date)
                      .where('tariffs.tariff_type_id = ? AND billable_items.billable_concept_id = ?', _type, _concept)
                      .order('subscriber_tariffs.starting_at')
                      .last rescue nil
    else
      self.subscriber.subscriber_tariffs.joins(tariff: :billable_item)
                      .where('(? BETWEEN subscriber_tariffs.starting_at AND subscriber_tariffs.ending_at) OR (? >= subscriber_tariffs.starting_at AND subscriber_tariffs.ending_at IS NULL)', _date, _date)
                      .where('tariffs.tariff_type_id = ? AND billable_items.billable_concept_id = ?', _type, _concept)
                      .where('tariffs.caliber_id = ?', _caliber)
                      .order('subscriber_tariffs.starting_at')
                      .last rescue nil
    end
  end


  # Special method to searchable
  def reading_incidence_type_ids
    reading_incidences.pluck(:reading_incidence_type_id)
  end

  #
  # CSV
  #
  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    attributes = [array[0].sanitize(I18n.t('activerecord.attributes.reading.meter_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.pre_reading.service_point_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.subscriber_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.subscriber_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.address')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.reading_route_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.sequence')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.report.reading.incidences')) ]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |reading|
        csv << [  reading.try(:meter).try(:meter_code),
                  reading.try(:service_point).try(:full_code),
                  reading.try(:subscriber).try(:full_code),
                  reading.try(:subscriber).try(:full_name_full),
                  reading.try(:subscriber).try(:address_1),
                  reading.try(:reading_route).try(:route_code),
                  reading.reading_sequence,
                  reading.reading_2.try(:billing_period).try(:period),
                  reading.reading_2.try(:to_reading_date),
                  reading.reading_2.try(:reading_index),
                  reading.reading_2.try(:reading_days),
                  reading.reading_2.try(:consumption_total_period),
                  reading.reading_1.try(:billing_period).try(:period),
                  reading.reading_1.try(:to_reading_date),
                  reading.reading_1.try(:reading_index),
                  reading.reading_1.try(:reading_days),
                  reading.reading_1.try(:consumption_total_period),
                  reading.try(:billing_period).try(:period),
                  reading.to_reading_date,
                  reading.reading_index,
                  reading.try(:reading_days),
                  reading.try(:consumption_total_period),
                  reading.reading_incidence_types.pluck(:name).join(", ")]
      end
    end
  end

  #
  # Sunspot indexes
  #
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
    string :by_period_date do
      billing_period_id
      reading_date
      sort_id
    end
    integer :reading_incidence_type, :multiple => true do
      reading_incidence_type_ids
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

  # PreBill create transaction
  def create_pre_bill(group_no, user_id, operation_id, cr, ce, co, cf)
    pre_bill = nil
    ActiveRecord::Base.transaction do
      pre_bill = PreBill.create( bill_no: nil,
                          pre_group_no: (group_no || PreBill.next_no),
                          project_id: project_id,
                          invoice_status_id: InvoiceStatus::PENDING,
                          bill_date: (billing_period.try(:prebilling_starting_date) || Date.today),
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

      subscriber.current_tariffs(reading_date).each do |tariffs_biller|
        pre_invoice = PreInvoice.create(
          invoice_no: nil,
          pre_bill_id: pre_bill.id,
          invoice_status_id: InvoiceStatus::PENDING,
          invoice_type_id: InvoiceType::WATER,
          invoice_date: (billing_period.try(:prebilling_starting_date) || Date.today),
          tariff_scheme_id: subscriber.tariff_scheme_id,
          payday_limit: billing_period.try(:prebilling_ending_date),
          invoice_operation_id: operation_id,
          billing_period_id: billing_period_id,
          consumption: cf,
          consumption_real: cr,
          consumption_estimated: ce,
          consumption_other: co,
          biller_id: tariffs_biller[0],
          discount_pct: 0.0,
          exemption: 0.0,
          charge_account_id: ChargeAccount.incomes(project_id).first.id,
          created_by: user_id,
          reading_1_date: reading_1.try(:reading_date),
          reading_2_date: reading_date,
          reading_1_index: reading_1.try(:reading_index),
          reading_2_index: reading_index
        )

        tariffs_biller[1].each do |tariff|    # tariff: current tariff for current reading
          # Computes & generates Preinvoice Items
          generate_pre_invoice_items(tariff, pre_invoice, pre_bill, cf, user_id)

          # Save totals in generated pre_invoice
          _i = PreInvoice.find(pre_invoice.id)
          _i.totals = _i.total
          _i.save
        end # tariffs_biller[1].each do |tariff|
      end # subscriber.current_tariffs(reading_date).each
    end # end transaction
    return pre_bill

  rescue ActiveRecord::RecordInvalid
    puts I18n.t(:transaction_error, var: "create_pre_bill")
  end
end
