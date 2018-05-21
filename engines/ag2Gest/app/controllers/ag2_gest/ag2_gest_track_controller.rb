require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class Ag2GestTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:water_supply_contract_report,
                                               :water_connection_contract_report,
                                               :contracting_request_report_track,
                                               :invoice_report,
                                               :invoice_items_report,
                                               :client_payment_report,
                                               :debt_claim_report,
                                               :reading_report,
                                               :sp_with_meter_report,
                                               :service_point_report,
                                               :subscriber_report_track,
                                               :subscriber_eco_report,
                                               :subscriber_eco_items_report,
                                               :subscriber_debt_report,
                                               :subscriber_debt_items_report,
                                               :subscriber_tec_report,
                                               :subscriber_invoice_charged_report,
                                               :client_eco_report,
                                               :client_eco_items_report,
                                               :client_debt_report,
                                               :client_debt_items_report,
                                               :client_invoice_charged_report,
                                               :meter_report,
                                               :meter_expired_report,
                                               :meter_shared_report,
                                               :meter_master_report]
    def water_supply_contract_report #case1
      detailed = params[:detailed]
      project = params[:project]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]
      subscriber = params[:subscriber]
      meter = params[:meter]
      caliber = params[:caliber]
      tariff_scheme = params[:tariff_scheme]
      reading_route = params[:reading_route]
      use = params[:use]
      request_status = params[:request_status]
      request_type = params[:request_type]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !project.blank?
        w += " AND " if w != ''
        w += "contracting_requests.project_id IN (#{project})"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.subscriber_id = #{subscriber}"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.caliber_id = '#{caliber}'"
      end
      if !tariff_scheme.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.tariff_scheme_id = '#{tariff_scheme}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.use_id = '#{use}'"
      end
      if !request_status.blank?
        w += " AND " if w != ''
        w += "contracting_requests.contracting_request_status_id = #{request_status}"
      end
      if !request_type.blank?
        w += " AND " if w != ''
        w += "contracting_requests.contracting_request_type_id = #{request_type}"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.contract_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.contract_date <= '#{@to_date.to_date}'"
      end

      @wsc_report = WaterSupplyContract.joins('LEFT JOIN contracting_requests ON contracting_requests.id=water_supply_contracts.contracting_request_id').where(w)

      # Setup filename
      title = t("activerecord.models.water_supply_contract.few") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@wsc_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        else
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def water_connection_contract_report #case2
        detailed = params[:detailed]
        project = params[:project]
        @from = params[:from]
        @to = params[:to]
        client = params[:client]
        caliber = params[:caliber]
        tariff_scheme = params[:tariff_scheme]
        request_status = params[:request_status]
        request_type = params[:request_type]

        # OCO
        init_oco if !session[:organization]
        if project.blank?
          @projects = projects_dropdown if @projects.nil?
          current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
          project = current_projects.join(",")
        end

        # Dates are mandatory
        if @from.blank? || @to.blank?
          return
        end

        # Format dates
        @from_date = @from
        @to_date = @to

        w = ''
        if !project.blank?
          w += " AND " if w != ''
          w += "contracting_requests.project_id IN (#{project})"
        end
        if !client.blank?
          w += " AND " if w != ''
          w += "water_connection_contracts.client_id = #{client}"
        end
        if !caliber.blank?
          w += " AND " if w != ''
          w += "water_connection_contracts.caliber_id = '#{caliber}'"
        end
        if !tariff_scheme.blank?
          w += " AND " if w != ''
          w += "water_connection_contracts.tariff_scheme_id = '#{tariff_scheme}'"
        end
        if !request_status.blank?
          w += " AND " if w != ''
          w += "contracting_requests.contracting_request_status_id = #{request_status}"
        end
        if !request_type.blank?
          w += " AND " if w != ''
          w += "contracting_requests.contracting_request_type_id = #{request_type}"
        end
        if !@from.blank?
          w += " AND " if w != ''
          w += "water_connection_contracts.contract_date >= '#{@from_date.to_date}'"
        end
        if !@to.blank?
          w += " AND " if w != ''
          w += "water_connection_contracts.contract_date <= '#{@to_date.to_date}'"
        end

        @wcc_report = WaterConnectionContract.joins('LEFT JOIN contracting_requests ON contracting_requests.id=water_connection_contracts.contracting_request_id').where(w)

        # Setup filename
        title = t("activerecord.models.water_connection_contract.few") + "_#{@from}_#{@to}"

        respond_to do |format|
          # Render PDF
          if !@wcc_report.blank?
            format.pdf { send_data render_to_string,
                         filename: "#{title}.pdf",
                         type: 'application/pdf',
                         disposition: 'inline' }
          else
            format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          end
        end
      end

    def contracting_request_report_track #case3
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      project = params[:project]
      client = params[:client]
      request_status = params[:request_status]
      request_type = params[:request_type]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to
      w = ''
      if !project.blank?
        w += " AND " if w != ''
        w += "contracting_requests.project_id IN (#{project})"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "water_supply_contracts.client_id = #{client}"
      end
      if !request_status.blank?
        w += " AND " if w != ''
        w += "contracting_requests.contracting_request_status_id = #{request_status}"
      end
      if !request_type.blank?
        w += " AND " if w != ''
        w += "contracting_requests.contracting_request_type_id = #{request_type}"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "contracting_requests.request_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "contracting_requests.request_date <= '#{@to_date.to_date}'"
      end

      @contracting_request_report = ContractingRequest.joins(:water_supply_contract).where(w).by_no

      # Setup filename
      title = t("activerecord.models.contracting_request.few") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@contracting_request_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        else
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def invoice_report #case4
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      project = params[:project]
      period = params[:period]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      # user = params[:user]
      biller = params[:biller]
      # meter = params[:meter]
      # caliber = params[:caliber]
      # service_point = params[:service_point]
      # tariff_scheme = params[:tariff_scheme]
      # reading_route = params[:reading_route]
      # request_status = params[:request_status]
      # request_type = params[:request_type]
      status = params[:status]
      type = params[:type]
      payment_method = params[:payment_method]
      operation = params[:operation]
      concept = params[:concept]
      # use = params[:use]
      # tariff_type = params[:tariff_type]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end

      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !project.blank?
        w += " AND " if w != ''
        w += "bills.project_id IN (#{project})"
      end
      if !period.blank?
        w += " AND " if w != ''
        w += "invoices.billing_period_id = #{period}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "bills.client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "bills.subscriber_id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !biller.blank?
        w += " AND " if w != ''
        w += "invoices.biller_id = #{biller}"
      end
      if !status.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_status_id = '#{status}'"
      end
      if !type.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_type_id = '#{type}'"
      end
      if !payment_method.blank?
        w += " AND " if w != ''
        w += "payment_methods.id = '#{payment_method}'"
      end
      if !operation.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_operation_id = '#{operation}'"
      end
      if !concept.blank?
        w += " AND " if w != ''
        w += "invoice_items.code = '#{BillableConcept.find(concept).code}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_date <= '#{@to_date.to_date}'"
      end
      @invoice_report = Invoice.joins(:bill)
                          .joins("LEFT JOIN subscribers ON bills.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN invoice_items ON invoice_items.invoice_id=invoices.id")
                          .joins("LEFT JOIN client_payments ON invoices.id=client_payments.invoice_id")
                          .joins("LEFT JOIN payment_methods ON payment_methods.id=client_payments.payment_method_id")
                          .where(w).by_no
      @invoice_report_csv = Invoice.to_csv_id(w)
      bills = []
      @invoice_report_csv.each do |pr|
        bills << Invoice.find(pr.p_id_).billable_concepts_array
      end
      bills = bills.flatten.uniq
      code = BillableConcept.where(id: bills)

      # Setup filename
      title = t("activerecord.models.invoice.few") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@invoice_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Bill.to_csv(@invoice_report_csv,code),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def invoice_items_report #case4
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      project = params[:project]
      period = params[:period]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      # user = params[:user]
      biller = params[:biller]
      # meter = params[:meter]
      # caliber = params[:caliber]
      # service_point = params[:service_point]
      # tariff_scheme = params[:tariff_scheme]
      # reading_route = params[:reading_route]
      # request_status = params[:request_status]
      # request_type = params[:request_type]
      status = params[:status]
      type = params[:type]
      payment_method = params[:payment_method]
      operation = params[:operation]
      concept = params[:concept]
      # use = params[:use]
      # tariff_type = params[:tariff_type]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end

      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !project.blank?
        w += " AND " if w != ''
        w += "bills.project_id IN (#{project})"
      end
      if !period.blank?
        w += " AND " if w != ''
        w += "invoices.billing_period_id = #{period}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "bills.client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "bills.subscriber_id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !biller.blank?
        w += " AND " if w != ''
        w += "invoices.biller_id = #{biller}"
      end
      if !status.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_status_id = '#{status}'"
      end
      if !type.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_type_id = '#{type}'"
      end
      if !operation.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_operation_id = '#{operation}'"
      end
      if !payment_method.blank?
        w += " AND " if w != ''
        w += "payment_methods.id = '#{payment_method}'"
      end
      if !concept.blank?
        w += " AND " if w != ''
        w += "invoice_items.code = '#{BillableConcept.find(concept).code}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_date <= '#{@to_date.to_date}'"
      end
      @invoice_report = Invoice.joins(:bill)
                          .joins("LEFT JOIN subscribers ON bills.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN invoice_items ON invoice_items.invoice_id=invoices.id")
                          .joins("LEFT JOIN client_payments ON invoices.id=client_payments.invoice_id")
                          .joins("LEFT JOIN payment_methods ON payment_methods.id=client_payments.payment_method_id")
                          .where(w).by_no
      @invoice_report_csv = Invoice.to_csv_id(w)
      bills = []
      @invoice_report_csv.each do |pr|
        bills << Invoice.find(pr.p_id_).billable_concepts_array
      end
      bills = bills.flatten.uniq
      code = BillableConcept.where(id: bills)

      # Setup filename
      title = t("activerecord.models.invoice.few") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@invoice_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Bill.to_csv(@invoice_report_csv,code),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def client_payment_report #case5
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      project = params[:project]
      period = params[:period]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      # user = params[:user]
      biller = params[:biller]
      # meter = params[:meter]
      # caliber = params[:caliber]
      # service_point = params[:service_point]
      # tariff_scheme = params[:tariff_scheme]
      # reading_route = params[:reading_route]
      # request_status = params[:request_status]
      # request_type = params[:request_type]
      status = params[:status]
      type = params[:type]
      payment_method = params[:payment_method]
      operation = params[:operation]
      concept = params[:concept]
      # use = params[:use]
      # tariff_type = params[:tariff_type]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end

      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !project.blank?
        w += " AND " if w != ''
        w += "bills.project_id IN (#{project})"
      end
      if !period.blank?
        w += " AND " if w != ''
        w += "invoices.billing_period_id = #{period}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "bills.client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "bills.subscriber_id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !biller.blank?
        w += " AND " if w != ''
        w += "invoices.biller_id = #{biller}"
      end
      if !status.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_status_id = '#{status}'"
      end
      if !type.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_type_id = '#{type}'"
      end
      if !payment_method.blank?
        w += " AND " if w != ''
        w += "payment_methods.id = '#{payment_method}'"
      end
      if !operation.blank?
        w += " AND " if w != ''
        w += "invoices.invoice_operation_id = '#{operation}'"
      end
      if !concept.blank?
        w += " AND " if w != ''
        w += "invoice_items.code = '#{BillableConcept.find(concept).code}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "client_payments.payment_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "client_payments.payment_date <= '#{@to_date.to_date}'"
      end
      @client_payment_report = ClientPayment.joins(:bill)
                          .joins("LEFT JOIN subscribers ON client_payments.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN invoices ON client_payments.invoice_id=invoices.id")
                          .joins("LEFT JOIN invoice_items ON invoice_items.invoice_id=invoices.id")
                          .joins("LEFT JOIN payment_methods ON payment_methods.id=client_payments.payment_method_id")
                          .where(w).by_no
      # Setup filename
      title = t("activerecord.models.client_payment.few") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@client_payment_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data ClientPayment.to_csv(@client_payment_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def debt_claim_report #case6
    end

    def reading_report #case7
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      project = params[:project]
      period = params[:period]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end

      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !project.blank?
        w += " AND " if w != ''
        w += "readings.project_id IN (#{project})"
      end
      if !period.blank?
        w += " AND " if w != ''
        w += "readings.billing_period_id = #{period}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "readings.subscriber_id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "readings.meter_id IN (#{meter.join(",")})"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "readings.service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "readings.reading_route_id = '#{reading_route}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "readings.reading_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "readings.reading_date <= '#{@to_date.to_date}'"
      end

      @reading_report = Reading.joins("LEFT JOIN subscribers ON readings.subscriber_id=subscribers.id")
                          .joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id")
                          .where(w).by_period_date

      # Setup filename
      title = t("activerecord.models.reading.few") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@reading_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Reading.to_csv(@reading_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def service_point_report #case8
      detailed = params[:detailed]
      meter = params[:meter]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      w += "service_points.office_id = #{session[:office]}"
      if !meter.blank?
        w += " AND " if w != ''
        w += "service_points.meter_id IN (#{meter.join(",")})"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_points.service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "service_points.reading_route_id = '#{reading_route}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.service_point_report.report_title")
      @service_point_report = ServicePoint.joins(:subscribers).where("service_points.available_for_contract <> ?", 0).where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@service_point_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data ServicePoint.to_csv(@service_point_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def sp_with_meter_report #case9
      detailed = params[:detailed]
      meter = params[:meter]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      w += "service_points.office_id = #{session[:office]}"
      if !meter.blank?
        w += " AND " if w != ''
        w += "service_points.meter_id IN (#{meter.join(",")})"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_points.service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "service_points.reading_route_id = '#{reading_route}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.service_point_report.report_meter_title")
      @sp_with_meter_report = ServicePoint.where("meter_id IS NOT NULL").where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@sp_with_meter_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data ServicePoint.to_csv(@sp_with_meter_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_report_track #case10
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_title") + "_#{@from}_#{@to}"
      @subscriber_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Subscriber.to_csv(@subscriber_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_eco_report #case11
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_eco_title") + "_#{@from}_#{@to}"
      @subscriber_eco_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_eco_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Subscriber.to_csv(@subscriber_eco_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_eco_items_report #case11
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_eco_title") + "_#{@from}_#{@to}"
      @subscriber_eco_items_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_eco_items_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Subscriber.to_csv(@subscriber_eco_items_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_tec_report #case12
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_tec_title") + "_#{@from}_#{@to}"
      @subscriber_tec_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_tec_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Subscriber.to_csv(@subscriber_tec_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_debt_report #case13
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      @todebt = params[:todebt]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_eco_title") + "_#{@from}_#{@to}"
      @subscriber_eco_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_eco_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Subscriber.to_csv(@subscriber_eco_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_debt_items_report #case13
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      @todebt = params[:todebt]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_eco_title") + "_#{@from}_#{@to}"
      @subscriber_eco_items_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_eco_items_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Subscriber.to_csv(@subscriber_eco_items_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def subscriber_invoice_charged_report #case14
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]
      use = params[:use]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if session[:office] != '0'
        w += "office_id = #{session[:office]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "client_id = #{client}"
      end
      if !subscriber.blank?
        w += " AND " if w != ''
        w += "id = #{subscriber}"
      end
      if !street_name.blank?
        w += " AND " if w != ''
        w += "subscriber_supply_addresses.supply_address IN ('#{street_name.join("','")}')"
      end
      if !meter.blank?
        w += " AND " if w != ''
        w += "meter_id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_point_id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "reading_route_id = '#{reading_route}'"
      end
      if !use.blank?
        w += " AND " if w != ''
        w += "use_id = '#{use}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "starting_at >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "starting_at <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.subscriber_report.report_fact_charged") + "_#{@from}_#{@to}"
      @subscriber_invoice_charged_report = Subscriber.joins("LEFT JOIN subscriber_supply_addresses ON subscriber_supply_addresses.subscriber_id=subscribers.id").activated.where(w).by_code

      respond_to do |format|
        # Render PDF
        if !@subscriber_invoice_charged_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def client_eco_report #case15
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]

      # OCO
      init_oco if !session[:organization]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !session[:organization].blank?
        w += " AND " if w != ''
        w += "clients.organization_id = #{session[:organization]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "clients.id = #{client}"
      end

      @client_debt_report = Client.where(w).by_code

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.client_report.report_title") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@client_debt_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Client.to_client_debt_csv(@client_debt_report,@from,@to),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def client_eco_items_report #case15
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]

      # OCO
      init_oco if !session[:organization]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !session[:organization].blank?
        w += " AND " if w != ''
        w += "clients.organization_id = #{session[:organization]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "clients.id = #{client}"
      end

      @client_debt_report = Client.where(w).by_code

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.client_report.report_title") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@client_debt_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          # format.csv { send_data Client.to_client_debt_csv(@client_debt_report,@from,@to),
          #              filename: "#{title}.csv",
          #              type: 'application/csv',
          #              disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def client_debt_report #case16
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      @todebt = params[:todebt]
      client = params[:client]

      # OCO
      init_oco if !session[:organization]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !session[:organization].blank?
        w += " AND " if w != ''
        w += "clients.organization_id = #{session[:organization]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "clients.id = #{client}"
      end

      @client_debt_report = Client.where(w).by_code

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.client_report.report_debt_title") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@client_debt_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Client.to_client_debt_csv(@client_debt_report,@from,@to),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def client_debt_items_report #case16
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      @todebt = params[:todebt]
      client = params[:client]

      # OCO
      init_oco if !session[:organization]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !session[:organization].blank?
        w += " AND " if w != ''
        w += "clients.organization_id = #{session[:organization]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "clients.id = #{client}"
      end

      @client_debt_report = Client.where(w).by_code

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.client_report.report_debt_title") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@client_debt_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          # format.csv { send_data Client.to_client_debt_csv(@client_debt_report,@from,@to),
          #              filename: "#{title}.csv",
          #              type: 'application/csv',
          #              disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def client_invoice_charged_report #case17
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      client = params[:client]

      # OCO
      init_oco if !session[:organization]

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !session[:organization].blank?
        w += " AND " if w != ''
        w += "clients.organization_id = #{session[:organization]}"
      end
      if !client.blank?
        w += " AND " if w != ''
        w += "clients.id = #{client}"
      end

      @client_invoice_charged_report = Client.where(w).by_code

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.client_report.report_fact_charged") + "_#{@from}_#{@to}"

      respond_to do |format|
        # Render PDF
        if !@client_invoice_charged_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def meter_report #case18
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      w += "meters.office_id = #{session[:office]}"
      if !meter.blank?
        w += " AND " if w != ''
        w += "meters.id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "meters.caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_points.id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "service_points.reading_route_id = '#{reading_route}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.meter_report.report_title") + "_#{@from}_#{@to}"
      @meter_report = Meter.joins(:service_points).where(w).order("service_points.reading_route_id, meters.meter_code")

      respond_to do |format|
        # Render PDF
        if !@meter_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Meter.to_csv(@meter_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def meter_expired_report #case19
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      w += "meters.office_id = #{session[:office]}"
      if !meter.blank?
        w += " AND " if w != ''
        w += "meters.id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "meters.caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_points.id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "service_points.reading_route_id = '#{reading_route}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.meter_report.report_expiry_title") + "_#{@from}_#{@to}"
      @meter_report = Meter.active_subscribers.expired.joins(:service_points).where(w).order("service_points.reading_route_id, meters.meter_code")

      respond_to do |format|
        # Render PDF
        if !@meter_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Meter.to_csv(@meter_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def meter_shared_report #case20
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      w += "meters.office_id = #{session[:office]}"
      if !meter.blank?
        w += " AND " if w != ''
        w += "meters.id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "meters.caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_points.id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "service_points.reading_route_id = '#{reading_route}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.meter_report.report_shared_title") + "_#{@from}_#{@to}"
      @meter_report = Meter.shared_all.joins(:service_points).where(w).order("service_points.reading_route_id, meters.meter_code")

      respond_to do |format|
        # Render PDF
        if !@meter_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Meter.to_csv(@meter_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def meter_master_report #case21
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      reading_route = params[:reading_route]

      # OCO
      init_oco if !session[:organization]
      meter = !meter.blank? ? inverse_meter_search(meter) : meter

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      w += "meters.office_id = #{session[:office]}"
      if !meter.blank?
        w += " AND " if w != ''
        w += "meters.id IN (#{meter.join(",")})"
      end
      if !caliber.blank?
        w += " AND " if w != ''
        w += "meters.caliber_id = #{caliber}"
      end
      if !service_point.blank?
        w += " AND " if w != ''
        w += "service_points.id = '#{service_point}'"
      end
      if !reading_route.blank?
        w += " AND " if w != ''
        w += "service_points.reading_route_id = '#{reading_route}'"
      end
      if !@from.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date >= '#{@from_date.to_date}'"
      end
      if !@to.blank?
        w += " AND " if w != ''
        w += "meters.purchase_date <= '#{@to_date.to_date}'"
      end

      # Setup filename
      title = t("ag2_gest.ag2_gest_track.meter_report.report_master_title") + "_#{@from}_#{@to}"
      @meter_report = Meter.master_meters.joins(:service_points).where(w).order("service_points.reading_route_id, meters.meter_code")

      respond_to do |format|
        # Render PDF
        if !@meter_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data Meter.to_csv(@meter_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    def default_report
      detailed = params[:detailed]
      @from = params[:from]
      @to = params[:to]
      project = params[:project]
      period = params[:period]
      client = params[:client]
      subscriber = params[:subscriber]
      street_name = params[:street_name]
      user = params[:user]
      biller = params[:biller]
      meter = params[:meter]
      caliber = params[:caliber]
      service_point = params[:service_point]
      tariff_scheme = params[:tariff_scheme]
      reading_route = params[:reading_route]
      request_status = params[:request_status]
      request_type = params[:request_type]
      status = params[:status]
      type = params[:type]
      operation = params[:operation]
      use = params[:use]
      tariff_type = params[:tariff_type]

      # OCO
      init_oco if !session[:organization]
      if project.blank?
        @projects = projects_dropdown if @projects.nil?
        current_projects = @projects.blank? ? [0] : current_projects_for_index(@projects)
        project = current_projects.join(",")
      end

      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      # Dates are mandatory
      if @from.blank? || @to.blank?
        return
      end

      # Format dates
      @from_date = @from
      @to_date = @to

      w = ''
      if !pr.blank?
        w += " AND " if w != ''
        w += "billable_items.project_id IN (#{pr})"
      end
      if !tt.blank?
        w += " AND " if w != ''
        w += "tariffs.tariff_type_id = #{tt}"
      end
      if !sa.blank?
        w += " AND " if w != ''
        w += "tariffs.starting_at >= '#{sa.to_date}'"
      end
      if !ea.blank?
        w += " AND " if w != ''
        w += "tariffs.ending_at <= '#{ea.to_date}'"
      end
      Tariff.all_group_tariffs_without_caliber(w)

      # Setup filename
      title = t("activerecord.models.offer_request.few") + "_#{from}_#{to}"

      respond_to do |format|
        # Render PDF
        if !@project_report.blank?
          format.pdf { send_data render_to_string,
                       filename: "#{title}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
          format.csv { send_data OfferRequest.to_csv(@project_report),
                       filename: "#{title}.csv",
                       type: 'application/csv',
                       disposition: 'inline' }
        else
          format.csv { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
          format.pdf { redirect_to ag2_gest_track_url, alert: I18n.t("ag2_purchase.ag2_purchase_track.index.error_report") }
        end
      end
    end

    #
    # Default Methods
    #
    def index
      project = params[:Project]
      period = params[:Period]
      client = params[:Client]
      subscriber = params[:Subscriber]
      street_name = params[:StreetName]
      user = params[:User]
      biller = params[:Biller]
      meter = params[:Meter]
      caliber = params[:Caliber]
      service_point = params[:ServicePoint]
      tariff_scheme = params[:TariffScheme]
      reading_route = params[:ReadingRoute]
      request_status = params[:RequestStatus]
      request_type = params[:RequestType]
      status = params[:Status]
      type = params[:Type]
      operation = params[:Operation]
      use = params[:Use]
      payment_method = params[:PaymentMethod]
      concept = params[:Concept]
      tariff_type = params[:TariffType]

      @reports = reports_array
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @project = !project.blank? ? Project.find(project).full_name : " "
      @period = !period.blank? ? BillingPeriod.find(period).to_label : " "
      @user = !user.blank? ? User.find(user).to_label : " "
      @client = !client.blank? ? Client.find(client).to_label : " "
      @subscriber = !subscriber.blank? ? Subscriber.find(subscriber).to_label : " "
      # @address = !street_name.blank? ? Subscriber.find(street_name).supply_address : " "
      @biller = !biller.blank? ? Company.find(biller).full_name : " "
      @service_point = !service_point.blank? ? ServicePoint.find(service_point).to_label : " "
      @reading_route = !reading_route.blank? ? ReadingRoute.find(reading_route).to_label : " "
      @tariff_schemes = tariff_schemes_dropdown if @tariff_schemes.nil?
      @request_statuses = request_statuses_dropdown if @request_statuses.nil?
      @request_types = request_types_dropdown if @request_types.nil?
      @status = invoice_statuses_dropdown if @status.nil?
      @types = invoice_types_dropdown if @types.nil?
      @operations = invoice_operations_dropdown if @operations.nil?
      @calibers = Caliber.by_caliber if @calibers.nil?
      @uses = Use.by_code if @uses.nil?
      @payment_methods = invoice_payment_methods_dropdown if @payment_methods.nil?
      @concepts = billable_concept_dropdown
      @tariff_types = TariffType.by_code if @tariff_types.nil?
    end

    private

    def reports_array()
      _array = []
      _array = _array << t("activerecord.models.water_supply_contract.few") #case1
      _array = _array << t("activerecord.models.water_connection_contract.few") #case2
      _array = _array << t("activerecord.models.contracting_request.few") #case3
      # _array = _array << t("activerecord.models.pre_bill.few")
      _array = _array << t("activerecord.models.invoice.few") #case4
      # _array = _array << t("activerecord.models.invoice.pending")
      _array = _array << t("activerecord.models.client_payment.few") #case5
      _array = _array << t("activerecord.models.debt_claim.few") #case6
      # _array = _array << t("activerecord.models.pre_reading.few")
      _array = _array << t("activerecord.models.reading.few") #case7

      _array = _array << t("ag2_gest.ag2_gest_track.service_point_report.report_title") #case8
      _array = _array << t("ag2_gest.ag2_gest_track.service_point_report.report_meter_title") #case9 sp_with_meter

      _array = _array << t("ag2_gest.ag2_gest_track.subscriber_report.report_title") #case10
      _array = _array << t("ag2_gest.ag2_gest_track.subscriber_report.report_eco_title") #case11
      _array = _array << t("ag2_gest.ag2_gest_track.subscriber_report.report_tec_title") #case12
      _array = _array << t("ag2_gest.ag2_gest_track.subscriber_report.report_debt_title") #case13
      _array = _array << t("ag2_gest.ag2_gest_track.subscriber_report.report_fact_charged") #case14

      _array = _array << t("ag2_gest.ag2_gest_track.client_report.report_title") #case15
      _array = _array << t("ag2_gest.ag2_gest_track.client_report.report_debt_title") #case16
      _array = _array << t("ag2_gest.ag2_gest_track.client_report.report_fact_charged") #case17

      _array = _array << t("ag2_gest.ag2_gest_track.meter_report.report_title") #case18
      _array = _array << t("ag2_gest.ag2_gest_track.meter_report.report_expiry_title") #case19
      _array = _array << t("ag2_gest.ag2_gest_track.meter_report.report_shared_title") #case20
      _array = _array << t("ag2_gest.ag2_gest_track.meter_report.report_master_title") #case21
      _array
    end

    def ret_array(_array, _ret, _id)
      if !_ret.nil?
        _ret.each do |_r|
          _array = _array << _r.read_attribute(_id) unless _array.include? _r.read_attribute(_id)
        end
      end
    end

    def projects_dropdown
      _array = []
      _projects = nil
      _offices = nil
      _companies = nil

      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _offices = current_user.offices
        if _offices.count > 1 # If current user has access to specific active company offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id = ? AND office_id IN (?)', session[:company].to_i, _offices)
        else
          _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
        end
      else
        _offices = current_user.offices
        _companies = current_user.companies
        if _companies.count > 1 and _offices.count > 1 # If current user has access to specific active organization companies or offices (more than one: not exclusive, previous if)
          _projects = Project.where('company_id IN (?) AND office_id IN (?)', _companies, _offices)
        else
          _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
        end
      end

      # Returning founded projects
      ret_array(_array, _projects, 'id')
      _projects = Project.where(id: _array).order(:project_code)
    end

    def current_projects_for_index(_projects)
      _current_projects = []
      _projects.each do |i|
        _current_projects = _current_projects << i.id
      end
      _current_projects
    end

    def tariff_schemes_dropdown
      TariffScheme.where(project_id: current_projects_ids)
    end

    def request_statuses_dropdown
      ContractingRequestStatus.order(:name)
    end

    def request_types_dropdown
      ContractingRequestType.order(:description)
    end

    def invoice_statuses_dropdown
      InvoiceStatus.all
    end

    def invoice_types_dropdown
      InvoiceType.all
    end

    def invoice_payment_methods_dropdown
      PaymentMethod.all
    end

    def invoice_operations_dropdown
      InvoiceOperation.all
    end

    def billable_concept_dropdown
        BillableConcept.all
    end

    def setup_no(no)
      no = no[0] != '%' ? '%' + no : no
      no = no[no.length-1] != '%' ? no + '%' : no
    end

    def inverse_meter_search(meter)
      _numbers = []
      no = setup_no(meter)
      Meter.where('meter_code LIKE ?', "#{no}").first(1000).each do |i|
        _numbers = _numbers << i.id
      end
      _numbers = _numbers.blank? ? meter : _numbers
    end

    def inverse_street_name_search(supply_address)
      _numbers = []
      no = setup_no(supply_address)
      SubscriberSupplyAddress.where('supply_address LIKE ?', "#{no}").first(1000).each do |i|
        _numbers = _numbers << i.supply_address.to_s
      end
      _numbers = _numbers.blank? ? supply_address : _numbers
    end

  end
end
