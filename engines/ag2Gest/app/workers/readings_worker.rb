class ReadingsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def expiration
    @expiration ||= 60*60*24*30 # 30 days
  end

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

  def pre_bill_reading_not_billed?(pre_bill)
    pre_bill.reading_2.bill_id.blank?
  end

  def perform(pre_bills_ids, payday_limit, invoice_date, confirmation_date, user_id)
    pre_bills = PreBill.where(pre_group_no: pre_bills_ids, bill_id: nil)
    pre_bills_count =  pre_bills.count
    final_bills = []

    pre_bills.each do |pre_bill|
      begin
        # reading_ids_subscriber_period = pre_bill.subscriber.readings.where(billing_period_id: pre_bill.reading_2.billing_period_id).map(&:id)
        # if Bill.where(reading_2_id: reading_ids_subscriber_period).blank? and Bill.select{|b| b.bill_operation == InvoiceOperation::INVOICE and b.bill_period == pre_bill.reading_2.billing_period_id and b.bill_type.id == InvoiceType::WATER and b.subscriber_id == pre_bill.subscriber_id}.blank?
        if pre_bill_reading_not_billed?(pre_bill)
          @bill = Bill.create!( bill_no: bill_next_no(pre_bill.project),
            project_id: pre_bill.project_id,
            invoice_status_id: InvoiceStatus::PENDING,
            bill_date: invoice_date,
            subscriber_id: pre_bill.subscriber_id,
            client_id: pre_bill.client_id,
            last_name: pre_bill.last_name,
            first_name: pre_bill.first_name,
            company: pre_bill.company,
            fiscal_id: pre_bill.fiscal_id,
            street_type_id: pre_bill.street_type_id,
            street_name: pre_bill.street_name,
            street_number: pre_bill.street_number,
            building: pre_bill.building,
            floor: pre_bill.floor,
            floor_office: pre_bill.floor_office,
            zipcode_id: pre_bill.zipcode_id,
            town_id: pre_bill.town_id,
            province_id: pre_bill.province_id,
            region_id: pre_bill.region_id,
            country_id: pre_bill.country_id,
            created_by: user_id,
            reading_1_id: pre_bill.reading_1_id,
            reading_2_id: pre_bill.reading_2_id,
            organization_id: pre_bill.project.organization_id )
          pre_bill.pre_invoices.map do |pre_invoice|
            @invoice = Invoice.create!( invoice_no: invoice_next_no(pre_invoice.biller_id, pre_bill.project.office_id),
              bill_id: @bill.id,
              invoice_status_id: InvoiceStatus::PENDING,
              invoice_type_id: InvoiceType::WATER,
              invoice_date: invoice_date,
              tariff_scheme_id: pre_invoice.tariff_scheme_id,
              payday_limit: payday_limit.blank? ? invoice_date : payday_limit,
              invoice_operation_id: InvoiceOperation::INVOICE,
              billing_period_id: pre_invoice.billing_period_id,
              consumption: pre_invoice.consumption,
              consumption_real: pre_invoice.consumption_real,
              consumption_estimated: pre_invoice.consumption_estimated,
              consumption_other: pre_invoice.consumption_other,
              biller_id: pre_invoice.biller_id,
              discount_pct: pre_invoice.discount_pct,
              exemption: pre_invoice.exemption,
              charge_account_id: pre_invoice.charge_account_id,
              created_by: user_id,
              reading_1_date: pre_invoice.reading_1_date,
              reading_2_date: pre_invoice.reading_2_date,
              reading_1_index: pre_invoice.reading_1_index,
              reading_2_index: pre_invoice.reading_2_index,
              organization_id: pre_bill.project.organization_id )
            pre_invoice.pre_invoice_items.map do |pre_invoice_item|
              InvoiceItem.create!( invoice_id: @invoice.id,
                code: pre_invoice_item.code,
                description: pre_invoice_item.description,
                tariff_id: pre_invoice_item.tariff_id,
                price:  pre_invoice_item.price,
                quantity: pre_invoice_item.quantity,
                tax_type_id: pre_invoice_item.tax_type_id,
                discount_pct: pre_invoice_item.discount_pct,
                discount: pre_invoice_item.discount,
                product_id: pre_invoice_item.product_id,
                subcode: pre_invoice_item.subcode,
                measure_id: pre_invoice_item.measure_id,
                created_by: user_id
              )
            end
            @bill.reading_2.update_attributes(bill_id: @bill.id)
            pre_bill.update_attributes(bill_id: @bill.id,confirmation_date: confirmation_date)
            # add mj
            pre_invoice.update_attributes(invoice_id: @invoice.id,confirmation_date: confirmation_date)

            # Save totals in generated invoice
            _i = Invoice.find(@invoice.id)
            _i.totals = _i.total
            _i.save
          end
          # add mj
          final_bills << @bill
        end
      rescue
        bgw = BackgroundWork.find_by_work_no(self.jid)
        bgw.update_attributes(failure: bgw.failure + "#{pre_bill.id}, ")
        next
      end
    end
    bgw = BackgroundWork.find_by_work_no(self.jid)
    bgw.update_attributes(total: pre_bills_count,
                          consumption: final_bills.map{|b| b.reading_2}.sum(&:consumption),
                          price_total: final_bills.sum(&:total),
                          total_confirmed: final_bills.count,
                          first_bill: (final_bills.first.full_no unless final_bills.blank?),
                          last_bill: (final_bills.last.full_no unless final_bills.blank?))

  end
end
