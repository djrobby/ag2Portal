# encoding: utf-8

# Replaceable latin symbols UTF-8 = ASCII-8BIT (ISO-8859-1)
# Á = \xC1  á = \xE1
# É = \xC9  é = \xE9
# Í = \xCD  í = \xED
# Ó = \xD3  ó = \xF3
# Ú = \xDA  ú = \xFA
# Ü = \xDC  ü = \xFC
# Ñ = \xD1  ñ = \xF1
# Ç = \xC7  ç = \xE7
# ¿ = \xBF  ¡ = \xA1
# ª = \xAA  º = \xBA

require_dependency "ag2_gest/application_controller"
# include Builder

module Ag2Gest
  class BillsToFilesController < ApplicationController
    before_filter :authenticate_user!
    before_filter :set_defaults
    # load_and_authorize_resource :worker
    skip_load_and_authorize_resource :only => :export_bills

    # Generate & export XML file
    def export_bills
      message = I18n.t("ag2_gest.bills_to_files.index.result_ok_message_html")
      @json_data = { "DataExport" => message, "Result" => "OK" }
      $alpha = "\xC1\xC9\xCD\xD3\xDA\xDC\xD1\xC7\xE1\xE9\xED\xF3\xFA\xFC\xF1\xE7\xBF\xA1\xAA\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
      $gamma = 'AEIOUUNCaeiouunc?!ao'
      $ucase = "\xC1\xC9\xCD\xD3\xDA\xDC\xD1\xC7".force_encoding('ISO-8859-1').encode('UTF-8')
      $lcase = "\xE1\xE9\xED\xF3\xFA\xFC\xF1\xE7".force_encoding('ISO-8859-1').encode('UTF-8')
      incidents = false
      message = ''

      bills = Bill.service.includes(:project, :reading_1, :reading_2, :client,
                                    subscriber: [:use, meter: [:caliber]], invoices:
                                   [:biller, :billing_period, invoice_items: [:tariff, :tax_type, :measure]]).last(2)
      xml = service_bills_to_xml(bills)
      upload_xml_file("some-file-name.xml", xml)

      if incidents
        message = I18n.t("ag2_gest.bills_to_files.index.result_ok_with_error_message_html") + message
        @json_data = { "DataExport" => message, "Result" => "ERROR" }
      end
      render json: @json_data
    end

    # Generates XML file
    def service_bills_to_xml(bills)
      consumption_t = I18n.t("activerecord.attributes.invoice_item.bl")
      from_t = I18n.t("activerecord.attributes.invoice_item.bl_from")
      to_t = I18n.t("activerecord.attributes.invoice_item.bl_to")
      more_t = I18n.t("activerecord.attributes.invoice_item.bl_more")
      single_t = I18n.t("activerecord.attributes.invoice_item.bl_single")
      from_d = I18n.t("activerecord.attributes.bill.label_from")
      to_d = I18n.t("activerecord.attributes.bill.label_to")
      tariff_d = I18n.t("activerecord.models.tariff.one")
      invoice_type_d = I18n.t("activerecord.models.invoice.one")
      concepts_detail_d = I18n.t("activerecord.attributes.report.detail").upcase
      invoice_d = I18n.t("activerecord.models.invoice.one")
      invoice_no_d = I18n.t("activerecord.models.invoice.one") + " " + I18n.t("activerecord.attributes.bill.bill_no")
      total_invoice_d = I18n.t("activerecord.attributes.bill.total")
      vat_rate_d = I18n.t("activerecord.attributes.contracting_request.iva_c")
      subtotal_invoice_d = I18n.t("activerecord.attributes.bill.subtotal")
      invoice_concept_d = I18n.t("activerecord.attributes.contracting_request.amount_title")
      invoice_payday_limit_d = I18n.t("ag2_gest.bills.index.payday_limit")

      bill_d = I18n.t("activerecord.models.bill.one")
      bill_no_d = I18n.t("activerecord.attributes.bill.bill_no")
      bill_date_d = I18n.t("activerecord.attributes.bill.bill_date")
      billing_period_d = I18n.t("activerecord.attributes.report.billing_period")
      bill_payday_limit_d = I18n.t("activerecord.attributes.bill.payday_limit")

      subscriber_d = I18n.t("activerecord.attributes.contracting_request.data_client")
      subscriber_code_d = I18n.t("activerecord.attributes.subscriber.subscriber_code")
      subscriber_holder_d = I18n.t("activerecord.attributes.subscriber.titular")
      subscriber_address_d = I18n.t("activerecord.report.subscriber.direction")
      subscriber_supply_d = I18n.t("activerecord.attributes.contracting_request.supply_data")
      subscriber_fiscal_id_d = I18n.t("activerecord.attributes.subscriber.fiscal_id_c")
      subscriber_use_d = I18n.t("activerecord.attributes.subscriber.use")

      meter_d = I18n.t("activerecord.attributes.contracting_request.data_meter")
      consumption_d = I18n.t("activerecord.attributes.contracting_request.consumption_data")
      previous_reading_d = I18n.t("activerecord.attributes.reading.lec_ant")
      current_reading_d = I18n.t("activerecord.attributes.reading.lec_act")
      m3_read_d = I18n.t("activerecord.attributes.reading.reg")
      m3_estimated_d = I18n.t("activerecord.attributes.reading.est")
      m3_others_d = I18n.t("activerecord.attributes.reading.other")
      m3_invoiced_d = I18n.t("activerecord.attributes.reading.fac")
      avg_consumption_d = I18n.t("activerecord.attributes.invoice.average_billed_consumption")

      tariffs_d = I18n.t("activerecord.models.tariff.zero")
      billing_d = I18n.t("activerecord.attributes.contracting_request.billing")
      total_bill_d = I18n.t("activerecord.attributes.bill.total") + " " + I18n.t("activerecord.models.invoice.one_or_many")
      total_receivable_d = I18n.t("activerecord.attributes.bill.total") + " " + I18n.t("activerecord.attributes.invoice.receivable_c")
      pending_debt_d = I18n.t("activerecord.attributes.bill.debt_c")
      currency_note_d = "* " + I18n.t("every_report.currency_note")
      payment_note_d = "* " + I18n.t("activerecord.attributes.bill.payment_note")
      payment_data_d = I18n.t("activerecord.attributes.contracting_request.payment_data")
      payment_supply_no_d = I18n.t("activerecord.attributes.water_supply_contract.supply_number")
      payment_supply_d = I18n.t("activerecord.attributes.billable_concept.supply")
      payment_bank_d = I18n.t("activerecord.models.client_bank_account.one")
      payment_issuer_d = I18n.t("activerecord.attributes.bill.issuer")
      payment_reference_d = I18n.t("activerecord.attributes.work_order_item.code")
      payment_ident_d = I18n.t("activerecord.attributes.bill.ident")

      block_codes = ["BL1", "BL2", "BL3", "BL4", "BL5", "BL6", "BL7", "BL8"]
      bridge = " | "

      # Initialize Builder
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      # xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8", :standalone => "yes"
      # xml.declare! :DOCTYPE, :bills, :PUBLIC, "-//W3C//DTD HTML 4.0 Transitional//EN", "http://www.w3.org/TR/REC-html40/loose.dtd"

      #+++ Begin +++
      xml.bills do  # Bills
        xml.company do  # Issuing company
          xml.name                bills.first.project.company.name
          xml.address_1           bills.first.project.company.address_1
          xml.address_2           bills.first.project.company.address_2
          xml.phone_and_fax       bills.first.project.company.phone_and_fax
          xml.email_and_website   bills.first.project.company.email_and_website
          xml.company_data        bills.first.project.company.invoice_footer_complete
        end
        bills.each do |bill|
          xml.bill(description: invoice_d) do  # Eeach bill
            xml.bill_no({ description: bill_no_d }, bill.real_no)
            xml.bill_date({ description: bill_date_d }, formatted_date(bill.bill_date))
            xml.billing_period({ description: billing_period_d }, bill.billing_period)
            xml.payday_limit({ description: bill_payday_limit_d }, bill.formatted_payday_limit)
            xml.subscriber(description: subscriber_d) do
              xml.code({ description: subscriber_code_d }, bill.subscriber.full_code)
              xml.holder({ description: subscriber_holder_d }, bill.subscriber.full_name)
              xml.address(description: subscriber_address_d) do
                xml.address_1     bill.subscriber.address_1
                xml.address_2     bill.subscriber.address_2
              end
              xml.supply(description: subscriber_supply_d) do
                xml.fiscal_id({ description: subscriber_fiscal_id_d }, bill.subscriber.fiscal_id)
                xml.use({ description: subscriber_use_d }, bill.subscriber.use_name)
              end
            end
            xml.client do
              xml.code          bill.client.full_code
              xml.name          bill.client.full_name
              xml.address_1     bill.client.address_1
              xml.address_2     bill.client.address_2
              xml.fiscal_id     bill.client.fiscal_id
            end
            xml.meter(description: meter_d) do
              xml.code          bill.subscriber.meter.meter_code
              xml.caliber       bill.subscriber.meter.caliber.caliber
            end
            xml.consumption(description: consumption_d) do
              xml.previous_reading(description: previous_reading_d) do
                xml.index       bill.formatted_reading_1_index
                xml.date        bill.formatted_reading_1_date
              end
              xml.current_reading(description: current_reading_d) do
                xml.index       bill.formatted_reading_2_index
                xml.date        bill.formatted_reading_2_date
              end
              xml.read({ description: m3_read_d }, bill.consumption_real)
              xml.estimated({ description: m3_estimated_d }, bill.consumption_estimated)
              xml.others({ description: m3_others_d }, bill.consumption_other)
              xml.invoiced({ description: m3_invoiced_d }, bill.consumption)
              xml.average({ description: avg_consumption_d }, bill.average_billed_consumption)
            end
            # Tariffs frame
            xml.tariffs(description: tariffs_d, separator: bridge) do
              bill.regulations.each do |r|
                regulation = Regulation.find(r[2]) rescue nil
                if !regulation.nil?
                  tariff_t = '(' + r[0] + ') ' + regulation.to_label
                  xml.tariff({ code: r[1] }, tariff_t)
                end
              end
            end
            # Total Bill & Pending debt
            xml.total({ description: total_bill_d }, number_with_precision(bill.total, precision: 2, delimiter: I18n.locale == :es ? "." : ","))
            xml.receivable({ description: total_receivable_d }, number_with_precision(bill.receivable, precision: 2, delimiter: I18n.locale == :es ? "." : ","))
            xml.pending_debt({ description: pending_debt_d }, number_with_precision(bill.debt, precision: 2, delimiter: I18n.locale == :es ? "." : ","))
            # Notes
            xml.currency_note   currency_note_d
            xml.payment_note    payment_note_d
            # Payment data
            xml.payment_data(description: payment_data_d) do
              xml.supply_no({ description: payment_supply_no_d }, bill.subscriber.full_code)
              xml.bill_no({ description: invoice_d + ' ' + bill_no_d }, bill.real_no)
              xml.bill_date({ description: bill_date_d }, formatted_date(bill.bill_date))
              xml.holder({ description: subscriber_holder_d }, bill.subscriber.full_name)
              xml.bank_account({ description: payment_bank_d }, bill.subscriber.full_name)
              xml.barcode do
                xml.issuer({ description: payment_issuer_d.upcase }, bill.issuer)
                xml.reference({ description: payment_reference_d.upcase }, bill.reference)
                xml.ident({ description: payment_ident_d.upcase }, bill.ident)
                xml.supply({ description: payment_supply_d.upcase }, bill.subscriber.subscriber_code[3..10])
                xml.payday_limit({ description: bill_payday_limit_d.upcase }, bill.formatted_payday_limit)
                xml.total({ description: total_invoice_d.upcase }, number_with_precision(bill.total, precision: 2))
              end
            end
            xml.invoices(description: billing_d) do   # Invoices
              bill.invoices.each do |invoice|
                # Is the first invoice? Set concepts_detail_d
                if invoice.id == bill.invoices.first.id
                  concepts_detail_d = I18n.t("activerecord.attributes.report.detail").upcase
                  invoice_type_name = invoice.invoice_type_name
                else
                  concepts_detail_d = ''
                  invoice_type_name = invoice.invoice_type_by_item_description
                end
                # Invoice type description
                if I18n.locale == :es
                  invoice_type_d = I18n.t("activerecord.models.invoice.one") + ' de ' + invoice_type_name
                else
                  invoice_type_d = invoice_type_name + ' ' + I18n.t("activerecord.models.invoice.one")
                end
                xml.invoice(description: invoice_type_d) do  # Each invoice
                  xml.invoice_no({ description: invoice_no_d }, invoice.full_no)
                  xml.invoice_date({ description: bill_date_d }, formatted_date(invoice.invoice_date))
                  xml.payday_limit({ description: invoice_payday_limit_d }, invoice.formatted_payday_limit)
                  # Biller
                  xml.biller do |biller|
                    xml.name        invoice.formatted_biller_name
                    xml.fiscal_id   invoice.formatted_biller_fiscal_id
                  end
                  # Subtotal
                  xml.subtotal({ description: subtotal_invoice_d }, number_with_precision(invoice.subtotal, precision: 2, delimiter: I18n.locale == :es ? "." : ","))
                  # Taxes
                  if invoice.tax_breakdown.count > 0
                    xml.vat_rates do
                      invoice.tax_breakdown.each do |tax|
                        if tax[0] != TaxType.exempt.tax
                          vat_description = vat_rate_d + " " + "(#{number_with_precision(tax[0], precision: 2)}%" + " de " + number_with_precision(tax[1], precision: 2) + ")"
                          xml.vat_rate({ description: vat_description }, number_with_precision(tax[2], precision: 2, delimiter: I18n.locale == :es ? "." : ","))
                        end
                      end
                    end
                  end
                  # Total
                  xml.total({ description: total_invoice_d }, number_with_precision(invoice.totals, precision: 2, delimiter: I18n.locale == :es ? "." : ","))
                  xml.items(description: concepts_detail_d) do  # Invoice items
                    invoice.ordered_invoiced_concepts.each do |concept, description, amount|
                      concept_description = invoice_concept_d + description
                      concept_amount = number_with_precision(amount, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                      # Regulation legends to apply to current concept
                      concept_regulations = ''
                      bill.regulations.each do |r|
                        if concept == r[1]
                          concept_regulations += '(' + r[0] + ')'
                        end
                      end
                      xml.concept(code: concept.upcase, name: description.upcase, description: concept_description) do  # Each invoice concept
                        xml.tariffs(concept_regulations)
                        xml.amount(concept_amount)
                        invoice_items = invoice.invoice_items_by_concept(concept)
                        # has_block_items = invoice.has_block_items?(invoice_items)
                        # Split current concept invoice items between blocks & non-blocks, and tariffs applied to blocks
                        no_block_items = invoice.no_block_items(invoice_items)
                        block_items = invoice.block_items(invoice_items)
                        block_item_tariffs = invoice.block_item_tariffs(block_items)
                        # Export non-block items
                        no_block_items.each do |item|
                          subcode_name = item.subcode_name
                          # Prorated?
                          if item.description[0] == '0' || item.description[0] == '1'
                            date_tariff = !item.tariff.ending_at.blank? ? to_d + " " + item.tariff_ending_at : from_d + " " + item.tariff_starting_at
                            subcode_name += " (" + tariff_d + " " + date_tariff + ")"
                          end
                          # Tax & measure
                          tax_pct = item.tax_type.tax rescue 0
                          measure = item.measure.description rescue ' '
                          # Regulation legend to apply to current item
                          item_regulation = ''
                          bill.regulations.each do |r|
                            if concept == r[1] && item.regulation == r[2]
                              item_regulation = '(' + r[0] + ')'
                              break
                            end
                          end
                          xml.item(code: item.subcode, description: subcode_name) do   # Each invoice item
                            xml.tariff      item_regulation
                            xml.measure     measure
                            xml.quantity    number_with_precision(item.quantity, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                            xml.price       number_with_precision(item.price, precision: 6, delimiter: I18n.locale == :es ? "." : ",")
                            xml.amount      number_with_precision(item.amount, precision: 4, delimiter: I18n.locale == :es ? "." : ",")
                            xml.tax_pct     number_with_precision(tax_pct, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                          end # xml.item do
                        end # no_block_items.each do |item|
                        # Export block items
                        block_item_tariffs.each do |tariff|
                          consumption_description = consumption_t
                          # Prorated?
                          if tariff[3] == '0'
                            consumption_description += " (" + tariff_d + " " + to_d + " " + tariff[2] + ")"
                          elsif tariff[3] == '1'
                            consumption_description += " (" + tariff_d + " " + from_d + " " + tariff[1] + ")"
                          end
                          xml.consumption(description: consumption_description) do  # Each consumption items
                            bll = -1
                            qty_ant = 0
                            block_items.each do |item|
                              # Only processes items belong to current tariff
                              if item.tariff_id != tariff[0]
                                next
                              end
                              # If it's a block, specify bounds
                              subcode_name = item.subcode_name
                              if block_codes.include? item.subcode  # It's a block
                                from = bll + 1
                                to = item.quantity + qty_ant
                                if item.tariff.instance_eval("block#{item.subcode[2].to_s}_limit").blank?
                                  if item.subcode == 'BL1' && item.tariff.block1_fee > 0  # Unique block
                                    subcode_name = single_t
                                  else
                                    subcode_name = more_t + from.to_i.to_s
                                  end
                                else
                                  subcode_name = from_t + from.to_i.to_s + to_t + to.to_i.to_s
                                end
                                qty_ant += item.quantity
                                bll = to
                              end
                              # Tax & measure
                              tax_pct = item.tax_type.tax rescue 0
                              measure = item.measure.description rescue ' '
                              # Regulation legend to apply to current item
                              item_regulation = ''
                              bill.regulations.each do |r|
                                if concept == r[1] && item.regulation == r[2]
                                  item_regulation = '(' + r[0] + ')'
                                  break
                                end
                              end
                              xml.item(code: item.subcode, description: subcode_name) do   # Each invoice item
                                xml.tariff      item_regulation
                                xml.measure     measure
                                xml.quantity    number_with_precision(item.quantity, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                                xml.price       number_with_precision(item.price, precision: 6, delimiter: I18n.locale == :es ? "." : ",")
                                xml.amount      number_with_precision(item.amount, precision: 4, delimiter: I18n.locale == :es ? "." : ",")
                                xml.tax_pct     number_with_precision(tax_pct, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                              end # xml.item do
                            end # block_items.each do |item|
                          end # xml.consumption do
                        end # block_item_tariffs.each do |tariff|
                      end # xml.concept do
                    end # invoice.ordered_invoiced_concepts.each do |concept|
                  end # xml.items do
                end # xml.invoice do
              end # bill.invoices.each do |invoice|
            end # xml.invoices do
          end # xml.bill do
        end # bills.each do |bill|
      end # xml.bills do
      #+++ End +++
    end

    # Upload XML file to Rails server (public/uploads)
    def upload_xml_file(file_name, xml)
      # Creates directory if it doesn't exist
      create_upload_dir
      # Save file to server's uploads dir
      file_to_upload = File.open(Rails.root.join('public', 'uploads', file_name), "wb")
      file_to_upload.write(xml)
      file_to_upload.close()
    end

    def create_upload_dir
      dir = Rails.root.join('public', 'uploads')
      Dir.mkdir(dir) unless File.exists?(dir)
    end

    # Save local XML file
    def save_xml_file(file_name, xml)
      file_to_upload = File.open(file_name, "w")
      file_to_upload.write(xml)
      file_to_upload.close()
    end

    # GET /bills_to_files
    # GET /bills_to_files.json
    def index
      # Authorize only if current user can read Bill
      authorize! :read, Bill
      # OCO
      init_oco if !session[:organization]
      @export = formats_array
      @projects = projects_dropdown
      @periods = projects_periods(@projects)
      @billers = billers_dropdown
    end

    private

    def formats_array()
      _array = []
      _array = _array << t("ag2_gest.bills_to_files.printed_bill")
      _array = _array << t("ag2_gest.bills_to_files.e_bill")
      _array
    end

    def set_defaults
      #@company = Company.first
      #@office = Office.find_by_company_id(@company)
      # @street_type = StreetType.first
      # @department = Department.first
      # @professional_group = ProfessionalGroup.first
      # @contract_type = ContractType.first
      # @collective_agreement = CollectiveAgreement.first
      # @zipcode = Zipcode.first
      # @worker_type = WorkerType.first
      # @degree_type = DegreeType.first
      # @organization = Organization.first
    end

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.belongs_to_office(session[:office].to_i)
      elsif session[:company] != '0'
        _projects = Project.belongs_to_company(session[:company].to_i)
      else
        _projects = session[:organization] != '0' ? Project.belongs_to_organization(session[:organization].to_i) : Project.by_code
      end
    end

    def projects_periods(_projects)
      BillingPeriod.belongs_to_projects(_projects)
    end

    def billers_dropdown
      session[:organization] != '0' ? Company.belongs_to_organization(session[:organization].to_i) : Company.by_name
    end
  end
end
