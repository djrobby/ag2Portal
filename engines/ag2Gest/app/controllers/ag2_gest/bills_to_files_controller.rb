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

      bills = Bill.service.includes(:reading_1, :reading_2, :client, :subscriber, invoices:
                                   [:biller, :billing_period, invoice_items: [:tariff, :product, :tax_type, :measure]]).first(2)
      xml = bills_to_xml(bills)
      upload_xml_file("some-file-name.xml", xml)

      if incidents
        message = I18n.t("ag2_gest.bills_to_files.index.result_ok_with_error_message_html") + message
        @json_data = { "DataExport" => message, "Result" => "ERROR" }
      end
      render json: @json_data
    end

    # Generates XML file
    def bills_to_xml(bills)
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!

      #+++ Begin +++
      xml.bills do  # Bills
        bills.each do |bill|
          xml.bill do   # Eeach bill
            xml.bill_no       bill.full_no
            xml.bill_date     formatted_date(bill.bill_date)
            xml.client        bill.client.full_name_or_company_code_fiscal
            xml.total         number_with_precision(bill.total, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
            xml.invoices do   # Invoices
              bill.invoices.each do |invoice|
                xml.invoice do  # Each invoice
                  xml.invoice_no    invoice.full_no
                  xml.invoice_date  formatted_date(invoice.invoice_date)
                  xml.total         number_with_precision(invoice.totals, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                  xml.items do  # Invoice items
                    invoice.ordered_invoiced_concepts.each do |concept, description|
                      xml.concept('code' => concept, 'description' => description) do  # Each invoice concept
                        invoice.invoice_items_by_concept(concept).each do |item|
                          subcode_name = item.subcode_name
                          if concept == 'BL1' || concept == 'BL2' || concept == 'BL3' || concept == 'BL4' ||
                             concept == 'BL5' || concept == 'BL6' || concept == 'BL7' || concept == 'BL8'
                            subcode_name = item.subcode_name
                          end
                          tax_pct = item.tax_type.blank? ? 0 : item.tax_type.tax
                          measure = item.measure.blank? ? ' ' : item.measure.description
                          xml.item('code' => item.subcode, 'description' => subcode_name) do   # Each invoice item
                            xml.measure     measure
                            xml.quantity    number_with_precision(item.quantity, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                            xml.price       number_with_precision(item.price, precision: 6, delimiter: I18n.locale == :es ? "." : ",")
                            xml.amount      number_with_precision(item.amount, precision: 4, delimiter: I18n.locale == :es ? "." : ",")
                            xml.tax_pct     number_with_precision(tax_pct, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
                          end # xml.item do
                        end # invoice.invoice_items_by_concept(concept).each do |item|
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

      # @bills_to_files = Invoice.all

      # respond_to do |format|
      #   format.html # index.html.erb
      #   format.json { render json: @bills_to_files }
      # end
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
