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
                                   [:biller, :billing_period, invoice_items: [:tariff, :tax_type, :measure]]).first(2)
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

      bill_d = I18n.t("activerecord.models.bill.one")
      bill_no_d = I18n.t("activerecord.attributes.bill.bill_no")
      bill_date_d = I18n.t("activerecord.attributes.bill.bill_date")
      billing_period_d = I18n.t("activerecord.attributes.report.billing_period")
      payday_limit_d = I18n.t("ag2_gest.bills.index.payday_limit")

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

      block_codes = ["BL1", "BL2", "BL3", "BL4", "BL5", "BL6", "BL7", "BL8"]

      # Initialize Builder
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!

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
          xml.bill(description: bill_d) do  # Eeach bill
            xml.bill_no({ description: bill_no_d }, bill.full_no)
            xml.bill_date({ description: bill_date_d }, formatted_date(bill.bill_date))
            xml.billing_period({ description: billing_period_d }, bill.billing_period)
            xml.payday_limit({ description: payday_limit_d }, bill.formatted_payday_limit)
            xml.subscriber(description: subscriber_d) do
              xml.code({ description: subscriber_code_d }, bill.subscriber.full_code)
              xml.holder({ description: subscriber_holder_d }, bill.subscriber.full_name)
              xml.address(description: subscriber_address_d) do
                xml.address_1     bill.subscriber.address_1
                xml.address_2     bill.subscriber.address_2
              end
              xml.supply(description: subscriber_supply_d) do
                xml.fiscal_id({ description: subscriber_fiscal_id_d }, bill.subscriber.fiscal_id)
                xml.use({ description: subscriber_use_d }, bill.subscriber.use.right_name)
              end
            end
            xml.client do
              xml.code          bill.client.full_code
              xml.holder        bill.client.full_name
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
            xml.tariffs(description: tariffs_d) do
            end
            xml.billing(description: billing_d) do
            end
            xml.total           number_with_precision(bill.total, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
            xml.invoices do   # Invoices
              bill.invoices.each do |invoice|
                if I18n.locale == :es
                  invoice_type_d = I18n.t("activerecord.models.invoice.one") + ' de ' + invoice.invoice_type_name
                else
                  invoice_type_d = invoice.invoice_type_name + ' ' + I18n.t("activerecord.models.invoice.one")
                end
                xml.invoice(description: invoice_type_d) do  # Each invoice
                  xml.invoice_no    invoice.full_no
                  xml.invoice_date  formatted_date(invoice.invoice_date)
                  xml.total         number_with_precision(invoice.totals, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                  xml.items do  # Invoice items
                    invoice.ordered_invoiced_concepts.each do |concept, description|
                      xml.concept(code: concept.upcase, description: description.upcase) do  # Each invoice concept
                        bll = -1
                        qty_ant = 0
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
                          tax_pct = item.tax_type.tax rescue 0
                          measure = item.measure.description rescue ' '
                          xml.item(code: item.subcode, description: subcode_name) do   # Each invoice item
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
                            block_items.each do |item|
                              subcode_name = item.subcode_name
                              if block_codes.include? item.subcode  # It's a block
                                from = bll + 1
                                to = item.quantity + qty_ant
                                if item.tariff.instance_eval("block#{item.subcode[2].to_s}_limit").blank?
                                  if item.subcode == 'BL1' && item.tariff.block1_fee > 0
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
                              tax_pct = item.tax_type.tax rescue 0
                              measure = item.measure.description rescue ' '
                              xml.item(code: item.subcode, description: subcode_name) do   # Each invoice item
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
      @projects = projects_dropdown
      @periods = projects_periods(@projects)
      @billers = billers_dropdown
    end

    private

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
