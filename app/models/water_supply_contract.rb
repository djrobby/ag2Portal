class WaterSupplyContract < ActiveRecord::Base

  belongs_to :bill
  belongs_to :caliber
  belongs_to :client
  belongs_to :contracting_request
  belongs_to :meter
  belongs_to :reading_route
  belongs_to :subscriber
  belongs_to :tariff_scheme
  belongs_to :work_order

  attr_accessible :bill_id, :cadastral_reference, :caliber_id, :client_id, :contract_date,
                  :contracting_request_id, :endowments, :gis_id, :inhabitants,
                  :installation_date, :meter_id, :reading_route_id, :reading_sequence,
                  :remarks, :subscriber_id, :tariff_scheme_id, :work_order_id, :installation_index

  searchable do
    integer :id
    integer :contracting_request_id
    integer :subscriber_id
    integer :reading_route_id
    integer :meter_id
    integer :tariff_scheme_id
    integer :caliber_id
    date :contract_date
  end
  # def tariffs_contract
  #   tariffs = tariff_scheme.try(:tariffs)
  #   unless tariffs.blank?
  #     tariffs.select{|t| t.try(:billable_item).try(:billable_concept).try(:billable_document) == 2}
  #     .select{|t| t.caliber.try(:id) == caliber.try(:id)}
  #     .group_by{|t| t.try(:billable_item).try(:biller_id)}
  #   else
  #     []
  #   end
  # end

  def generate_bill
    bill = Bill.create( bill_no: bill_next_no(contracting_request.project),
                        project_id: contracting_request.project_id,
                        invoice_status_id: InvoiceStatus::PENDING,
                        bill_date: Date.today,
                        subscriber_id: subscriber_id, #nil
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
                        country_id: client.country_id)
                          # project_id: contracting_request.project_id,
                          # invoice_status_id: 1, #Nestor
                          # bill_no: bill_next_no(contracting_request.project),
                          # bill_date: Date.today,
                          # subscriber_id: subscriber_id)
      tariff_scheme.tariffs_contract(caliber_id).each do |tariffs_biller|
        invoice = Invoice.create( invoice_no: invoice_next_no(contracting_request.try(:project).try(:company_id)),
                                bill_id: bill.id,
                                invoice_status_id: InvoiceStatus::PENDING,
                                invoice_type_id: InvoiceType::CONTRACT,
                                invoice_date: Date.today,
                                tariff_scheme_id: tariff_scheme.id,
                                payday_limit: nil,
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
                                charge_account_id: client.client_bank_accounts.active.first.try(:id),
                                )
        tariffs_biller[1].each do |tariff|
          InvoiceItem.create( invoice_id: invoice.id,
                              code: tariff.try(:billable_item).try(:billable_concept).try(:code),
                              description: tariff.try(:billable_item).try(:billable_concept).try(:name),
                              tariff_id: tariff.id,
                              price: tariff.try(:fixed_fee),
                              quantity: 1,
                              tax_type_id: tariff.try(:tax_type_f_id),
                              discount_pct: tariff.try(:discount_pct_f),
                              discount: 0.0,
                              product_id: nil,
                              subcode: tariff.try(:billable_item).try(:billable_concept).try(:code),
                              measure_id: tariff.billing_frequency.fix_measure_id)
      end
    end
    self.bill_id = bill.id
    if self.save
      return bill
    else
      return nil
    end
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
        code = project + year + '0000001'
      else
        last_no = last_no[16..22].to_i + 1
        code = project + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

  # Invoice no
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
        code = company + year + '0000001'
      else
        last_no = last_no[8..14].to_i + 1
        code = company + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

end
