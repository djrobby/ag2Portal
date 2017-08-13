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

require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class PurchaseToFilesController < ApplicationController
    before_filter :authenticate_user!
    # before_filter :set_defaults
    before_filter :set_params
    skip_load_and_authorize_resource :only => [:export_suppliers, :export_supplier_invoices]

    def export_suppliers
      message = I18n.t("ag2_purchase.purchase_to_files.index.result_error_message_html")
      @json_data = { "DataExport" => message, "Result" => "ERROR" }

      # Dates are mandatory
      if @from.blank? || @to.blank?
        render json: @json_data and return
      end
      # Search necessary data
      organization = nil
      company = Company.find(@company_id) rescue nil
      if company.blank?
        render json: @json_data and return
      else
        organization = company.organization_id rescue nil
        if organization.blank?
          render json: @json_data and return
        end
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      suppliers = Supplier.by_organization_and_creation_date(organization, from, to)
      if suppliers.blank?
        message = I18n.t("ag2_purchase.purchase_to_files.index.result_ok_with_error_message_html")
        @json_data = { "DataExport" => message, "Result" => "ERROR" }
        render json: @json_data and return
      end

      message = I18n.t('ag2_purchase.purchase_to_files.index.result_ok_message_html', total: suppliers.count)
      link_message1 = I18n.t('ag2_purchase.purchase_to_files.index.go_to_target', var: 'SIS_CLIENTES_PROVEEDORES')

      file_name = 'SIS_CLIENTES_PROVEEDORES_' + Time.new.strftime("%Y%m%d%H%M%S") + '.csv'
      upload_xml_file(file_name, Supplier.to_csv(suppliers, company.id))
      @json_data = { "DataExport" => message, "Result" => "OK",
                     "File1" => "/uploads/" + file_name, "LinkMessage1" => link_message1 }
      # save_local_file('SIS_CLIENTES_PROVEEDORES.csv', Supplier.to_csv(suppliers))
      render json: @json_data
    rescue
      message = I18n.t("ag2_purchase.purchase_to_files.index.result_error_message_html")
      @json_data = { "DataExport" => message, "Result" => "ERROR" }
      render json: @json_data
    end

    def export_supplier_invoices
      message = I18n.t("ag2_purchase.purchase_to_files.index.result_error_message_html")
      @json_data = { "DataExport" => message, "Result" => "ERROR" }

      # Dates are mandatory
      if @from.blank? || @to.blank?
        render json: @json_data and return
      end
      # Search necessary data
      organization = nil
      projects = nil
      company = Company.find(@company_id) rescue nil
      if company.blank?
        render json: @json_data and return
      else
        organization = company.organization_id rescue nil
        projects = company.projects rescue nil
        if organization.blank? || projects.blank?
          render json: @json_data and return
        end
      end

      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")

      supplier_invoices = SupplierInvoice.by_projects_and_creation_date(projects, from, to)
      if supplier_invoices.blank?
        message = I18n.t("ag2_purchase.purchase_to_files.index.result_ok_with_error_message_html")
        @json_data = { "DataExport" => message, "Result" => "ERROR" }
        render json: @json_data and return
      end

      message = I18n.t('ag2_purchase.purchase_to_files.index.result_ok_message_html', total: supplier_invoices.count)
      link_message1 = I18n.t('ag2_purchase.purchase_to_files.index.go_to_target', var: 'SIS_MOVCONTA')
      link_message2 = I18n.t('ag2_purchase.purchase_to_files.index.go_to_target', var: 'SIS_CARTERAEFECTOS')

      file_name1 = 'SIS_MOVCONTA_' + Time.new.strftime("%Y%m%d%H%M%S") + '.csv'
      file_name2 = 'SIS_CARTERAEFECTOS_' + Time.new.strftime("%Y%m%d%H%M%S") + '.csv'
      upload_xml_file(file_name1, SupplierInvoice.to_csv(supplier_invoices, company.id))
      upload_xml_file(file_name2, SupplierInvoice.effects_portfolio_to_csv(supplier_invoices, company.id))
      @json_data = { "DataExport" => message, "Result" => "OK",
                     "File1" => "/uploads/" + file_name1, "LinkMessage1" => link_message1,
                     "File2" => "/uploads/" + file_name2, "LinkMessage2" => link_message2 }
      # save_local_file('SIS_MOVCONTA.csv', SupplierInvoice.to_csv(supplier_invoices))
      render json: @json_data
    # rescue
    #   message = I18n.t("ag2_purchase.purchase_to_files.index.result_error_message_html")
    #   @json_data = { "DataExport" => message, "Result" => "ERROR" }
    #   render json: @json_data
    end

    # GET /bills_to_files
    # GET /bills_to_files.json
    def index
      # Authorize only if current user can read Supplier
      authorize! :read, Supplier
      # OCO
      init_oco if !session[:organization]
      @export = formats_array
      # @projects = projects_dropdown
      # @periods = projects_periods(@projects)
      @billers = billers_dropdown
    end

    private

    def formats_array()
      _array = []
      _array = _array << t("ag2_purchase.purchase_to_files.suppliers_file")
      _array = _array << t("ag2_purchase.purchase_to_files.invoices_file")
      _array
    end

    def set_params
      @company_id = params[:company]
      @from = params[:from]
      @to = params[:to]

      @company_id = @company_id.to_i
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
