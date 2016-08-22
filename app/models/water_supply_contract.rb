class WaterSupplyContract < ActiveRecord::Base
  belongs_to :contracting_request
  belongs_to :client
  belongs_to :subscriber
  belongs_to :reading_route
  belongs_to :work_order
  belongs_to :meter
  belongs_to :tariff_scheme
  belongs_to :bill
  belongs_to :caliber

  attr_accessible :bill_id, :cadastral_reference, :caliber_id, :client_id, :contract_date,
                  :contracting_request_id, :endowments, :gis_id, :inhabitants,
                  :installation_date, :installation_index, :meter_id, :reading_route_id, :reading_sequence,
                  :remarks, :subscriber_id, :tariff_scheme_id, :work_order_id

  # validates

  # callbacks

  # methods
  def generate_bill
    bill = Bill.create(project_id: contracting_request.project_id,
                          invoice_status_id: 1, #Nestor
                          bill_no: bill_next_no(contracting_request.project),
                          bill_date: Date.today,
                          subscriber_id: subscriber_id)
      tariff_scheme.tariffs_contract(caliber_id).each do |tariffs_biller|
      invoice = Invoice.create(
        bill_id: bill.id,
        invoice_no: invoice_next_no(contracting_request.try(:project).try(:company_id)),
        invoice_date: Date.today,
        invoice_status_id: 1, #Nestor
        invoice_type_id: 1,
        tariff_scheme_id: tariff_scheme.id,
        company_id: tariffs_biller[0]
      ) #Nestor
      tariffs_biller[1].each do |tariff|
        InvoiceItem.create(
          invoice_id: invoice.id,
          code: tariff.try(:billable_item).try(:billable_concept).try(:code),
          description: tariff.try(:billable_item).try(:billable_concept).try(:name),
          quantity: 1,
          price: tariff.try(:fixed_fee),
          tax_type_id: tariff.try(:tax_type_f_id),
          discount_pct: tariff.try(:discount_pct_f),
          tariff_id: tariff.id)
      end
    end
    self.bill_id = bill.id
    if self.save
      return bill
    else
      return nil
    end
  end

  searchable do
    string :gis_id
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
        code = company + year + '000001'
      else
        last_no = last_no[8..14].to_i + 1
        code = company + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end
end
