require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SubscribersController < ApplicationController
    #include ActionView::Helpers::NumberHelper
    @@subscribers = nil

    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :su_remove_filters,
                                                :su_restore_filters,
                                                :subscriber_pdf,
                                                :create,
                                                :add_meter,
                                                :quit_meter,
                                                :change_meter,
                                                :su_find_meter,
                                                :su_find_invoice_to_period,
                                                :simple_bill,
                                                :update_simple,
                                                :update_tariffs,
                                                :void,
                                                :subscriber_report,
                                                :subscriber_tec_report,
                                                :subscriber_eco_report,
                                                :rebilling,
                                                :add_bank_account,
                                                :sub_check_iban,
                                                :update_country_textfield_from_region,
                                                :update_region_textfield_from_province,
                                                :update_province_textfield_from_town,
                                                :update_province_textfield_from_zipcode,
                                                :sub_load_postal,
                                                :sub_load_bank,
                                                :sub_load_dropdowns,
                                                :add_tariff_new,
                                                :add_bill_new,
                                                :sub_load_debt,
                                                :sub_sepa_pdf,
                                                :non_billable_button,
                                                :reset_estimation,
                                                :billable_button,
                                                :disable_bank_account,
                                                :disable_tariff_button,
                                                :su_check_invoice_date ]
    # Helper methods for
    helper_method :sort_column
    # => index filters
    helper_method :su_remove_filters, :su_restore_filters

    def su_check_invoice_date
      code = ''
      office = Office.find(params[:office_id])
      new_bill_date = params[:invoice_date]
      new_bill_date = (new_bill_date[0..3] + '-' + new_bill_date[4..5] + '-' + new_bill_date[6..7]).to_date

      if !Bill.is_new_bill_date_valid?(new_bill_date, office.company_id, office.id)
        code = I18n.t("activerecord.attributes.bill.alert_invoice_date")
      end
      render json: { "code" => code }
    end

    # update subscriber estimation
    def reset_estimation
      @subscriber = Subscriber.find(params[:id])
      @subscriber.current_estimation.update_attributes(estimation_reset_at: Time.now)
      @json_data = { "id" => @subscriber.id }
      render json: @json_data
    end

    # update true subscriber non-billable
    def non_billable_button
      @subscriber = Subscriber.find(params[:id])
      if @subscriber.non_billable == false
        @subscriber.update_attributes(non_billable: true)
      end
      @json_data = { "non_billable" => @subscriber.non_billable }
      render json: @json_data
    end

    # update false subscriber non-billable
    def billable_button
      @subscriber = Subscriber.find(params[:id])
      if @subscriber.non_billable == true
        @subscriber.update_attributes(non_billable: false)
      end
      @json_data = { "billable" => @subscriber.non_billable }
      render json: @json_data
    end

    # disable client bank account
    def disable_bank_account
      @subscriber = Subscriber.find(params[:id])
      # @client_bank_account = ClientBankAccount.find(params[:cba_id])
      _bank_account = @subscriber.client_bank_accounts.where(id: params[:cba_id]).first
      _bank_account.update_attributes(ending_at: Date.today)
      redirect_to subscriber_path(@subscriber) + "#debits"
    end

    # disable tariff
    def disable_tariff_button
      @subscriber = Subscriber.find(params[:id])
      # @client_bank_account = ClientBankAccount.find(params[:cba_id])
      _tariff = SubscriberTariff.where('id = ? and subscriber_id = ?',params[:st_id], params[:id])
      _tariff.update_all(ending_at: Date.today)
      redirect_to subscriber_path(@subscriber) + "#tariffs"
    end

    # Update country text field at view from region select
    def update_country_textfield_from_region
      @region = Region.find(params[:id])
      @country = Country.find(@region.country)

      respond_to do |format|
        format.html # update_country_textfield_from_region.html.erb does not exist! JSON only
        format.json { render json: @country }
      end
    end

    # Update region and country text fields at view from town select
    def update_region_textfield_from_province
      @province = Province.find(params[:id])
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update province, region and country text fields at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update town, province, region and country text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @region = Region.find(@province.region)
      @country = Country.find(@region.country)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    def sub_sepa_pdf
      @subscriber = Subscriber.find(params[:id])

      title = t("activerecord.attributes.water_supply_contract.pay_sepa_order_c")
      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "#{title}_#{@subscriber.full_code}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    def update_tariffs
      @subscriber = Subscriber.find(params[:id])
      @caliber = @subscriber.meter.caliber_id
      _tariff_type_ids = params[:TariffType_]
      _billable_item_ids = params[:BillableConcept_]
      _new_ids = []
      tariffs = Tariff.availables_to_project_types_items_document_caliber(_billable_item_ids, @subscriber.tariffs.first.billable_item.project_id, _tariff_type_ids, 1, @caliber)

      tariffs.each do |a|
        @subscriber.tariffs << a
        _new_ids = _new_ids << @subscriber.subscriber_tariffs.last.id
      end

      _new_tariff = SubscriberTariff.where('id in (?)',_new_ids)
      _new_tariff.update_all(starting_at: Date.today)

      if tariffs.blank?
        redirect_to subscriber_path(@subscriber) + "#tariffs", alert: "No existen tarifas"
      else
        redirect_to subscriber_path(@subscriber) + "#tariffs", notice: "Tarifas actualizada correctamente"
      end
    end

    def update_simple
      @subscriber = Subscriber.find params[:id]
      params[:invoice_item].each do |obj_inv|
        invoice_item = InvoiceItem.find_by_id(obj_inv[0])
        _i = Invoice.find(invoice_item.invoice_id) if invoice_item
        _i.totals = _i.total if invoice_item
        _i.save if invoice_item
        invoice_item.update_attributes(obj_inv[1]) if invoice_item
      end
      redirect_to subscriber_path(@subscriber), notice: "Factura actualizada correctamente"
    end

    def void
      @subscriber = Subscriber.find params[:id]
      @bill = Bill.find params[:bill_id]
      void_bill(@bill)
      redirect_to subscriber_path(@subscriber), notice: "Factura anulada"
    end

    def rebilling
      @subscriber = Subscriber.find params[:id]
      @bill = Bill.find params[:bill_id]
      @reading = @bill.reading_2
      if @bill.nullable?
        @bill_voided = void_bill(@bill)
      else
        @bill_voided = @bill
      end
      invoice_date = Date.today
      payday_limit = invoice_date + @subscriber.office.days_for_invoice_due_date
      @bill = @reading.generate_bill(bill_next_no(@reading.project), current_user.try(:id), 3, payday_limit, invoice_date)
      # @reading.generate_pre_bill(nil,nil,3)
      Sunspot.index! [@bill] unless @bill.blank?

      @subscriber_readings = Reading.by_subscriber_full(params[:id]).paginate(:page => params[:page] || 1, :per_page => 10)
      invoice_status = (0..99).to_a.join(',')
      @subscriber_bills = Bill.by_subscriber_full(params[:id], invoice_status).paginate(:page => params[:page] || 1, :per_page => 10)

      respond_to do |format|
        format.js { render "simple_bill" }
      end
    end

    # Check IBAN
    def sub_check_iban
      iban = check_iban(params[:country], params[:dc], params[:bank], params[:office], params[:account])
      # Setup JSON
      @json_data = { "iban" => iban }
      render json: @json_data
    end

    def add_bank_account
      @subscriber = Subscriber.find(params[:id])
      @countries = Country.order(:name)
      @bank = banks_dropdown
      @bank_offices = bank_offices_dropdown
      _class = params[:client_bank_account][:bank_account_class_id]
      if !@subscriber.client_bank_accounts.where(ending_at: nil,bank_account_class_id: _class).blank?
        _bank_account = @subscriber.client_bank_accounts.where('bank_account_class_id = ?', _class).order("ending_at").active
        _bank_account.update_all(ending_at: params[:client_bank_account][:starting_at])
        # @subscriber.client.client_bank_accounts.where(ending_at: nil).update_all(ending_at: params[:client_bank_account][:starting_at])
        redirect_to @subscriber, alert: t('ag2_gest.subscribers.client_bank_account.fail_assing_ending_at') and return if !_bank_account.empty?
      end
      @client_bank_account = ClientBankAccount.new(
                              client_id: params[:client_bank_account][:client_id],
                              subscriber_id: params[:client_bank_account][:subscriber_id],
                              bank_account_class_id: params[:client_bank_account][:bank_account_class_id],
                              starting_at: params[:client_bank_account][:starting_at],
                              country_id: params[:client_bank_account][:country_id],
                              iban_dc: params[:client_bank_account][:iban_dc],
                              bank_id: params[:client_bank_account][:bank_id],
                              bank_office_id: params[:client_bank_account][:bank_office_id],
                              # ccc_dc: params[:client_bank_account][:account_no].to_s[0..1],
                              account_no: params[:client_bank_account][:account_no].to_s[0..11],
                              holder_fiscal_id: params[:client_bank_account][:holder_fiscal_id],
                              holder_name: params[:client_bank_account][:holder_name]
                            )
      if @client_bank_account.save
        redirect_to subscriber_path(@subscriber) + "#debits", notice: t('ag2_gest.subscribers.client_bank_account.successful')
      else
        redirect_to subscriber_path(@subscriber) + "#debits", alert: t('ag2_gest.subscribers.client_bank_account.failure')
      end
    end

    #
    # Meter installation
    #
    def add_meter
      @subscriber = Subscriber.find(params[:id])
      @service_point = @subscriber.service_point
      @meter = Meter.find params[:reading][:meter_id]
      @billing_period = BillingPeriod.find params[:reading][:billing_period_id]
      project = params[:reading][:project_id] || @billing_period.project_id
      save_all_ok = false

      # #Create Reading
      @reading = Reading.new( project_id: project,
                   billing_period_id: @billing_period.id,
                   reading_type_id: ReadingType::INSTALACION, #ReadingType Installation
                   meter_id: @meter.id,
                   subscriber_id: @subscriber.id,
                   service_point_id: @service_point.id,
                   reading_date: params[:reading][:reading_date],
                   reading_index: params[:reading][:reading_index],
                   reading_route_id: @subscriber.reading_route_id,
                   reading_sequence: @subscriber.reading_sequence,
                   reading_variant: @subscriber.reading_variant,
                   billing_frequency_id: @billing_period.billing_frequency_id,
                   reading_1: nil,
                   reading_2: nil,
                   reading_index_1: nil,
                   reading_index_2: nil )
      @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:incidence_type_ids])

      # #Create MeterDetail
      @meter_detail = MeterDetail.new( meter_id: @meter.id,
                                       subscriber_id: @subscriber.id,
                                       installation_date:  params[:reading][:reading_date],
                                       installation_reading: params[:reading][:reading_index],
                                       meter_location_id: params[:reading][:meter_location_id],
                                       withdrawal_date: nil,
                                       withdrawal_reading: nil )
      # Update Meter first_installation_date if appropiate
      if @meter.first_installation_date.blank? || @meter_detail.installation_date < @meter.first_installation_date
        @meter.first_installation_date = @meter_detail.installation_date
      end

      # #Update caliber WaterSupplyContract (NO!!! contract is historical info)
      # @water_supply_contract = @subscriber.water_supply_contract
      # @water_supply_contract.caliber_id = @meter.caliber_id

      # Assign meter
      # @subscriber.meter_id = @meter.id

      # Try to save everything
      if (@meter_detail.save and @reading.save)
        @subscriber.update_attributes(active: true, meter_id: @meter.id)
        if @service_point.meter_id.blank?
          @subscriber.service_point.update_attributes(meter_id: @meter.id, reading_sequence: @subscriber.reading_sequence, reading_variant: @subscriber.reading_variant, reading_route_id: @subscriber.reading_route_id)
          @reading.update_attributes(coefficient: @meter.shared_coefficient)
        end
        save_all_ok = true
        if @meter.first_installation_date != @meter.first_installation_date_was # first_installation_date has changed, save it
          if !@meter.save
            save_all_ok = false
          end
        end
      else
        save_all_ok = false
      end

      respond_to do |format|
        if save_all_ok
          format.html { redirect_to @subscriber, notice: t('activerecord.attributes.subscriber.add_meter_successful') }
          format.json { render json: @reading, status: :created, location: @reading }
        else
          format.html { redirect_to @subscriber, alert: t('activerecord.attributes.subscriber.add_meter_failure') }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end
    end

    #
    # Meter withdrawal
    #
    def quit_meter
      @subscriber = Subscriber.find(params[:id])
      @service_point = @subscriber.service_point
      @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])
      @meter = @subscriber.meter
      project = params[:reading][:project_id] || @billing_period.project_id
      save_all_ok = false

      if @meter.is_shared?
        redirect_to @subscriber, alert: t('activerecord.attributes.subscriber.quit_meter_shared_failure') and return
      else
        #Create Reading
        @reading = Reading.new( project_id: project,
                     billing_period_id: params[:reading][:billing_period_id],
                     reading_type_id: ReadingType::RETIRADA, #ReadingType Withdrawal
                     meter_id: @subscriber.meter_id,
                     subscriber_id: @subscriber.id,
                     service_point_id: @service_point.id,
                     coefficient: @meter.shared_coefficient,
                     reading_date: params[:reading][:reading_date],
                     reading_index: params[:reading][:reading_index]
                  )

        rdg_1 = set_reading_1_to_reading(@subscriber,@subscriber.meter,@billing_period)
        rdg_2 = set_reading_2_to_reading(@subscriber,@subscriber.meter,@billing_period)
        @reading.reading_1 = rdg_1
        @reading.reading_index_1 = rdg_1.try(:reading_index)
        @reading.reading_2 = rdg_2
        @reading.reading_index_2 = rdg_2.try(:reading_index)
        @reading.reading_sequence = @subscriber.reading_sequence
        @reading.reading_variant = @subscriber.reading_variant
        @reading.reading_route_id = @subscriber.reading_route_id
        @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
        @reading.created_by = current_user.id if !current_user.nil?

        @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:incidence_type_ids])

        # Update MeterDetail associated
        @meter_detail = MeterDetail.where(subscriber_id: @subscriber.id, meter_id: @subscriber.meter_id, withdrawal_date: nil).first
        @meter_detail.withdrawal_date = params[:reading][:reading_date] unless @meter_detail.blank?
        @meter_detail.withdrawal_reading = params[:reading][:reading_index] unless @meter_detail.blank?
        # Update Meter last_withdrawal_date if appropiate
        if @meter.shared_coefficient == 0 && (@meter.last_withdrawal_date.blank? || @meter_detail.withdrawal_date > @meter.last_withdrawal_date)
          @meter.last_withdrawal_date = @meter_detail.withdrawal_date
        end

        #Put Caliber Nil (NO!!! contract is historical info)
        #@water_supply_contract = @subscriber.water_supply_contract
        #@water_supply_contract.caliber_id = nil

        # Remove meter from subscriber

        # Try to save everything
        if (@meter_detail.save and @reading.save)
          @subscriber.update_attributes(active: false, meter_id: nil)
          if @service_point.meter_id == @meter.id && @service_point.subscribers.activated.count == 0
            @subscriber.service_point.update_attributes(meter_id: nil)
          end
          save_all_ok = true
          if @meter.last_withdrawal_date != @meter.last_withdrawal_date_was # last_withdrawal_date has changed, save it
            if !@meter.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end
      end #@meter.is_shared?


      respond_to do |format|
        if save_all_ok
          format.html { redirect_to @subscriber, notice: t('activerecord.attributes.subscriber.quit_meter_successful') }
          format.json { render json: @reading, status: :created, location: @reading }
        else
          format.html { redirect_to @subscriber, alert: t('activerecord.attributes.subscriber.quit_meter_failure') }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end
    end

    #
    # Meter change
    #
    def change_meter
      # Quit meter
      @subscriber = Subscriber.find(params[:id])
      @service_point = @subscriber.service_point
      @billing_period_q = BillingPeriod.find(params[:reading][:q_billing_period_id])
      @meter_q = @subscriber.meter
      @meter_master = Meter.find(@subscriber.meter)
      project = @billing_period_q.project_id
      save_all_ok = false

      if @meter_q.is_shared?
        redirect_to @subscriber, alert: t('activerecord.attributes.subscriber.quit_meter_shared_failure') and return
      else
        #Create Reading
        @reading_q = Reading.new( project_id: project,
                     billing_period_id: params[:reading][:q_billing_period_id],
                     reading_type_id: ReadingType::RETIRADA, #ReadingType Withdrawal
                     meter_id: @subscriber.meter_id,
                     subscriber_id: @subscriber.id,
                     service_point_id: @service_point.id,
                     coefficient: @meter_q.shared_coefficient,
                     reading_date: params[:reading][:q_reading_date],
                     reading_index: params[:reading][:q_reading_index]
                  )

        rdg_1 = set_reading_1_to_reading(@subscriber,@subscriber.meter,@billing_period_q)
        rdg_2 = set_reading_2_to_reading(@subscriber,@subscriber.meter,@billing_period_q)
        @reading_q.reading_1 = rdg_1
        @reading_q.reading_index_1 = rdg_1.try(:reading_index)
        @reading_q.reading_2 = rdg_2
        @reading_q.reading_index_2 = rdg_2.try(:reading_index)
        @reading_q.reading_sequence = @subscriber.reading_sequence
        @reading_q.reading_variant = @subscriber.reading_variant
        @reading_q.reading_route_id = @subscriber.reading_route_id
        @reading_q.billing_frequency_id = @billing_period_q.try(:billing_frequency_id)
        @reading_q.created_by = current_user.id if !current_user.nil?

        @reading_q.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:reading][:q_reading_incidence_type_ids])

        # Update MeterDetail associated
        @m_detail_q = MeterDetail.where(subscriber_id: @subscriber.id, meter_id: @subscriber.meter_id, withdrawal_date: nil).first
        @m_detail_q.withdrawal_date = params[:reading][:q_reading_date] unless @m_detail_q.blank?
        @m_detail_q.withdrawal_reading = params[:reading][:q_reading_index] unless @m_detail_q.blank?
        # Update Meter last_withdrawal_date if appropiate
        if @meter_q.shared_coefficient == 0 && (@meter_q.last_withdrawal_date.blank? || @m_detail_q.withdrawal_date > @meter_q.last_withdrawal_date)
          @meter_q.last_withdrawal_date = @m_detail_q.withdrawal_date
        end

        #Put Caliber Nil (NO!!! contract is historical info)
        #@water_supply_contract = @subscriber.water_supply_contract
        #@water_supply_contract.caliber_id = nil

        # Try to save everything
        if (@m_detail_q.save and @reading_q.save)
          @subscriber.update_attributes(active: false, meter_id: nil)
          if @service_point.meter_id == @meter_q.id && @service_point.subscribers.activated.count == 0
            @subscriber.service_point.update_attributes(meter_id: nil)
          end
          save_all_ok = true
          if @meter_q.last_withdrawal_date != @meter_q.last_withdrawal_date_was # last_withdrawal_date has changed, save it
            if !@meter_q.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end

        redirect_to @subscriber, alert: t('activerecord.attributes.subscriber.quit_meter_failure') and return if !save_all_ok

        # Add meter
        @meter_a = Meter.find params[:reading][:meter_id]
        @billing_period_a = BillingPeriod.find(params[:reading][:a_billing_period])

        # #Create Reading
        @reading_a = Reading.new( project_id: project,
                     billing_period_id: @billing_period_a.id,
                     reading_type_id: ReadingType::INSTALACION, #ReadingType Installation
                     meter_id: @meter_a.id,
                     subscriber_id: @subscriber.id,
                     service_point_id: @service_point.id,
                     reading_date: params[:reading][:a_reading_date],
                     reading_index: params[:reading][:a_reading_index],
                     reading_route_id: @subscriber.reading_route_id,
                     reading_sequence: @subscriber.reading_sequence,
                     reading_variant: @subscriber.reading_variant,
                     billing_frequency_id: @billing_period_a.billing_frequency_id,
                     reading_1: nil,
                     reading_2: nil,
                     reading_index_1: nil,
                     reading_index_2: nil )

        @reading_a.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:reading][:a_reading_incidence_type_ids])

        # #Create MeterDetail
        @m_detail_a = MeterDetail.new( meter_id: @meter_a.id,
                                         subscriber_id: @subscriber.id,
                                         installation_date:  params[:reading][:a_reading_date],
                                         installation_reading: params[:reading][:a_reading_index],
                                         meter_location_id: params[:reading][:meter_location_id],
                                         withdrawal_date: nil,
                                         withdrawal_reading: nil )
        # Update Meter first_installation_date if appropiate
        if @meter_a.first_installation_date.blank? || @m_detail_a.installation_date < @meter_a.first_installation_date
          @meter_a.first_installation_date = @m_detail_a.installation_date
        end
        if !@meter_master.master_meter_id.blank?
          @meter_a.master_meter_id = @meter_master.master_meter_id
        end

        # Try to save everything
        if (@m_detail_a.save and @reading_a.save)
          @subscriber.update_attributes(active: true, meter_id: @meter_a.id)
          if @service_point.meter_id.blank?
            @subscriber.service_point.update_attributes(meter_id: @meter_a.id, reading_sequence: @subscriber.reading_sequence, reading_variant: @subscriber.reading_variant, reading_route_id: @subscriber.reading_route_id)
            @reading_a.update_attributes(coefficient: @meter_a.shared_coefficient)
          end
          save_all_ok = true
          if @meter_a.first_installation_date != @meter_a.first_installation_date_was # first_installation_date has changed, save it
            if !@meter_a.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end
      end

      respond_to do |format|
        if save_all_ok
          format.html { redirect_to @subscriber, notice: t('activerecord.attributes.subscriber.add_meter_successful') }
          format.json { render json: @reading_a, status: :created, location: @reading_a }
        else
          format.html { redirect_to @subscriber, alert: t('activerecord.attributes.subscriber.add_meter_failure') }
          format.json { render json: @reading_a.errors, status: :unprocessable_entity }
        end
      end
    end

    #
    # Look for meter
    #
    def su_find_meter
      m = params[:meter]
      alert = ""
      code = ''
      meter_id = 0
      if m != '$'
        meter = Meter.find_by_meter_code(m) rescue nil
        if !meter.nil?
          s = Subscriber.find_by_meter_id(meter.id) rescue nil
          if s.nil?
            # Meter available
            alert = I18n.t("activerecord.errors.models.meter.available", var: m)
            meter_id = meter.id
          else
            # Meter installed and unavailable
            # Meter can be tested for been installed using meter.is_installed_now?
            alert = I18n.t("activerecord.errors.models.meter.installed", var: m)
            code = '$err'
          end
        else
          # Meter code not found
          alert = I18n.t("activerecord.errors.models.meter.code_not_found", var: m)
          code = '$err'
        end
      else
        # Wrong meter code
        alert = I18n.t("activerecord.errors.models.meter.code_wrong", var: m)
        code = '$err'
      end
      # Setup JSON
      @json_data = { "code" => code, "alert" => alert, "meter_id" => meter_id.to_s }
      render json: @json_data
    end

    def su_find_invoice_to_period
      subscriber = Subscriber.find(params[:subscriber_id])
      period = BillingPeriod.find(params[:period])
      bill_last_date = formatted_date(Bill.last_billed_date(period.project.company_id, period.project.office_id)) rescue "N/A"
      alert_date = I18n.t("activerecord.attributes.bill.alert_invoice_date_bills") + " " + bill_last_date
      alert_bill = ""
      code_bill = ''
      bill_original = ''
      bill_void = ''

      bills = Bill.service_by_project_period_subscriber(period.project_id, period.id, subscriber.id)
      bills.each do |b|
        if b.bill_operation == 1
          bill_original = 1
        end
        if b.bill_operation == 2
          bill_void = 2
        end
      end

      if bill_original == '' && bill_void == ''
        alert_bill = I18n.t("activerecord.attributes.subscriber.alert_fact")
        code_bill = '$fact'
      end
      if bill_original == 1 && bill_void == 2
        alert_bill = I18n.t("activerecord.attributes.subscriber.alert_refact")
        code_bill = '$refact'
      end
      if (bill_original == 1 && bill_void == '') || (bill_original == '' && bill_void == 2)
        alert_bill = I18n.t("activerecord.attributes.subscriber.alert_without_original")
        code_bill = '$err'
      end

      # Setup JSON
      @json_data = { "code_bill" => code_bill, "alert_bill" => alert_bill, "alert_date" => alert_date }
      render json: @json_data
    end

    def subscriber_pdf
      @subscriber = Subscriber.find(params[:id])
      @billing_periods = BillingPeriod.all
      #@from = params[:from]
      #@to = params[:to]

      #from = Time.parse(@from).strftime("%Y-%m-%d")
      #to = Time.parse(@to).strftime("%Y-%m-%d")

      #@water_supply_contract = @contracting_request.water_supply_contract
      #@bill = @water_supply_contract.bill

      respond_to do |format|
        format.pdf {
          send_data render_to_string, filename: "SCR-#{@subscriber.id}.pdf", type: 'application/pdf', disposition: 'inline'
        }
      end
    end

    def sub_load_postal
      subscriber = Subscriber.find(params[:subscriber_id])
      street_type_id = 0
      zipcode_id = 0
      town_id = 0
      province_id = 0
      region_id = 0
      country_id = 0

      street_type_id = !subscriber.postal_street_type_id.blank? ? subscriber.postal_street_type_id : subscriber.client.street_type_id
      zipcode_id = !subscriber.postal_zipcode_id.blank? ? subscriber.postal_zipcode_id : subscriber.client.zipcode_id
      town_id = !subscriber.postal_town_id.blank? ? subscriber.postal_town_id : subscriber.client.town_id
      province_id = !subscriber.postal_province_id.blank? ? subscriber.postal_province_id : subscriber.client.province_id
      region_id = !subscriber.postal_region_id.blank? ? subscriber.postal_region_id : subscriber.client.region_id
      country_id = !subscriber.postal_country_id.blank? ? subscriber.postal_country_id : subscriber.client.country_id
      @json_data = { "towns" => towns_array, "provinces" => provinces_array, "zipcodes" => zipcodes_array,
                     "regions" => regions_array, "countries" => country_array, "street_types" => street_types_array,
                      "town_id" => town_id, "province_id" => province_id, "zipcode_id" => zipcode_id,
                      "region_id" => region_id, "country_id" => country_id, "street_type_id" => street_type_id }
      render json: @json_data
    end

    def sub_load_bank
      # subscriber = Subscriber.find(params[:subscriber_id])
      bank_id = 0
      bank_office_id = 0
      bank_account_class_id = 0
      country_id = 0
      @json_data = { "banks" => banks_array, "bank_offices" => bank_offices_array,
                     "bank_account_classes" => bank_account_classes_array, "countries" => country_array,
                     "bank_id" => bank_id, "bank_office_id" => bank_office_id,
                     "bank_account_class_id" => bank_account_class_id, "country_id" => country_id }
      render json: @json_data
    end

    def sub_load_debt
      subscriber = Subscriber.find(params[:subscriber_id])
      current_debt = number_with_precision(subscriber.total_existing_debt, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
      current_debt_label = I18n.t('activerecord.attributes.subscriber.debt') + ':'
      @json_data = { "current_debt" => current_debt, "current_debt_label" => current_debt_label }
      render json: @json_data
    end

    #*** Charge modal dropdowns async ***
    def sub_load_dropdowns
      subscriber = Subscriber.find(params[:subscriber_id])

      # current_debt = number_with_precision(subscriber.total_existing_debt, precision: 2, delimiter: I18n.locale == :es ? "." : ",")
      # current_debt_label = I18n.t('activerecord.attributes.subscriber.debt') + ':'

      street_type_id = !subscriber.postal_street_type_id.blank? ? subscriber.postal_street_type_id : subscriber.client.street_type_id
      zipcode_id = !subscriber.postal_zipcode_id.blank? ? subscriber.postal_zipcode_id : subscriber.client.zipcode_id
      town_id = !subscriber.postal_town_id.blank? ? subscriber.postal_town_id : subscriber.client.town_id
      province_id = !subscriber.postal_province_id.blank? ? subscriber.postal_province_id : subscriber.client.province_id
      region_id = !subscriber.postal_region_id.blank? ? subscriber.postal_region_id : subscriber.client.region_id
      country_id = !subscriber.postal_country_id.blank? ? subscriber.postal_country_id : subscriber.client.country_id

      @json_data = { "towns" => towns_array, "provinces" => provinces_array, "zipcodes" => zipcodes_array,
                     "regions" => regions_array, "countries" => country_array, "street_types" => street_types_array,
                      "town_id" => town_id, "province_id" => province_id, "zipcode_id" => zipcode_id,
                      "region_id" => region_id, "country_id" => country_id, "street_type_id" => street_type_id,
                      "banks" => banks_array, "bank_offices" => bank_offices_array,
                      "bank_account_classes" => bank_account_classes_array, "meter_location" => meter_locations_array,
                      "billing_period" => billing_periods_array(subscriber), "projects" => projects_array,
                      "reading_type" => reading_types_array }
                      # "billing_periods_reading" => billing_period_readings_array(subscriber)
                      # "billable_concept_availables" => billable_concepts_available_array(subscriber)
                      # "current_debt" => current_debt, "current_debt_label" => current_debt_label
      render json: @json_data
    end

    def add_tariff_new
      subscriber = Subscriber.find(params[:subscriber_id])
      @json_data = { "billable_concept_availables" => billable_concepts_available_array(subscriber)}
      render json: @json_data
    end

    def add_bill_new
      subscriber = Subscriber.find(params[:subscriber_id])
      @json_data = { "billing_periods_reading" => billing_period_readings_array(subscriber)}
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /subscribers
    # GET /subscribers.json
    def index
      manage_filter_state
      filter = params[:ifilter]
      subscriber_code = params[:SubscriberCode]
      street_name = params[:StreetName]
      meter = params[:Meter]
      caliber = params[:Caliber]
      use = params[:Use]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @address = !street_name.blank? ? Subscriber.find(street_name).supply_address : " "
      @calibers = Caliber.by_caliber if @calibers.nil?
      @uses = Use.by_code if @uses.nil?
      @tariff_types = TariffType.by_code if @tariff_types.nil?
      #@service_points = service_points_dropdown if @service_points.nil?
      #@meters = meters_dropdown if @meters.nil?

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code
      meter = !meter.blank? ? inverse_meter_search(meter) : meter
      # street_name = !street_name.blank? ? inverse_street_name_search(street_name) : street_name

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        # if !street_name.blank?
        #   if street_name.class == Array
        #     with :supply_address, street_name
        #   else
        #     with(:supply_address).starting_with(street_name)
        #   end
        # end
        if !street_name.blank?
          with :subscriber_id, street_name
        end
        if !meter.blank?
          if meter.class == Array
            with :meter_code, meter
          else
            with(:meter_code).starting_with(meter)
          end
        end
        if !caliber.blank?
          with :caliber_id, caliber
        end
        if !use.blank?
          with :use_id, use
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        if !filter.blank?
          case filter
            when 'all'
              any_of do
                with :subscribed, true
                with :unsubscribed, true
              end
            when 'subscribed'
              with :subscribed, true
            when 'unsubscribed'
              with :unsubscribed, true
            when 'active'
              with :activated, true
            when 'inactive'
              with :deactivated, true
          end
        end
        data_accessor_for(Subscriber).include = [:street_directory, :meter]
        order_by :sort_no, :desc
        paginate :page => params[:page] || 1, :per_page => per_page || 10
      end
      @subscribers = @search.results
      @@subscribers = Subscriber.where(id: @subscribers.map(&:id)).by_code_desc
      @reports = reports_array

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @subscribers }
        format.js
      end
    end

    # GET /subscribers/1
    # GET /subscribers/1.json
    def show
      manage_filter_state_show
      filter = params[:ifilter_show] || "pending"
      @active_ifilter = filter
      filter_tariff = params[:ifilter_show_tariff] || "active"
      @active_ifilter_tariff = filter_tariff
      filter_account = params[:ifilter_show_account] || "active"
      @active_ifilter_account = filter_account

      @breadcrumb = 'read'
      if !@@subscribers.nil?
        begin
          @subscriber = @@subscribers.find(params[:id])
          @nav = @@subscribers
        rescue
          @subscriber = Subscriber.find(params[:id])
          @nav = Subscriber
        end
      else
        @subscriber = Subscriber.find(params[:id])
        @nav = Subscriber
      end
      # @subscriber = Subscriber.find(params[:id])
      # @subscriber = Subscriber.find_with_joins(params[:id]).first

      @service_point = @subscriber.service_point rescue nil
      @meter = @subscriber.meter rescue nil
      @meter_is_shared = @subscriber.meter.is_shared? rescue false
      @client = Client.find(@subscriber.client_id)
      @current_debt = @subscriber.current_debt

      #*** For modal dropdowns ***
      # _add_meter, _new_reading
      @reading = Reading.new
      # _add_meter, _change_meter, _quit_meter, _new_reading
      @meter_location = []
      @billing_period = []
      @reading_incidence = ReadingIncidenceType.all
      # _new_reading
      @project_dropdown = []
      @reading_type = []
      # _change_data_supply
      @street_types = []
      @towns = []
      @provinces = []
      @zipcodes = []
      @regions = []
      # _change_data_supply, _new_client_bank_account
      @countries = []
      # _new_client_bank_account
      @bank = []
      @bank_offices = []
      @bank_account_classes = []
      # modals in show
      @billing_periods_reading = []
      # modals show_tab_tariffs
      @billable_concept_availables = []

      # _tariff_type_ids = []
      # _tariffs = !@subscriber.water_supply_contract.blank? ? @subscriber.contracted_tariffs : @subscriber.subscriber_tariffs
      # _tariffs.each do |tt|
      #   if !_tariff_type_ids.include? tt.tariff.tariff_type.id
      #     _tariff_type_ids << tt.tariff.tariff_type.id
      #   end
      # end
      # @tariffs_dropdown = Tariff.current_by_type_and_use_in_service_invoice_full(_tariff_type_ids)
      # modals show_tab_tariffs

      if filter_tariff == "all"
        @subscriber_tariffs = SubscriberTariff.to_subscriber_full(@subscriber.id).paginate(:page => params[:tariff_page] || 1, :per_page => 10)
      else
        @subscriber_tariffs = SubscriberTariff.availables_to_subscriber_full(@subscriber.id).paginate(:page => params[:tariff_page] || 1, :per_page => 10)
      end

      ### Bank accounts ###
      if filter_account == "all"
        @subscriber_accounts = ClientBankAccount.by_subscriber_full(@subscriber.id)
        @subscriber_accounts = ClientBankAccount.by_client_full(@subscriber.client_id) if @subscriber_accounts.blank?
      else
        @subscriber_accounts = ClientBankAccount.active_by_subscriber_full(@subscriber.id)
        @subscriber_accounts = ClientBankAccount.active_by_client_full(@subscriber.client_id) if @subscriber_accounts.blank?
      end
      @subscriber_accounts = @subscriber_accounts.paginate(:page => params[:account_page] || 1, :per_page => 10)

      ### Readings ###
      @subscriber_readings = Reading.by_subscriber_full(@subscriber.id).paginate(:page => params[:reading_page] || 1, :per_page => 10)
      @subscriber_readings_average = (@subscriber_readings.sum(&:consumption) / @subscriber_readings.size).round rescue 0
      # @subscriber_readings = @subscriber.readings.paginate(:page => params[:page], :per_page => 5)
      # search_readings = Reading.search do
      #   with :subscriber_id, params[:id]
      #   data_accessor_for(Reading).include = [:meter, :billing_period, :reading_type, :reading_incidences, :reading_incidence_types]
      #   order_by :sort_id, :desc
      #   paginate :page => params[:page] || 1, :per_page => per_page || 10
      # end
      # @subscriber_readings = search_readings.results

      ### Bills ###
      invoice_status = (0..99).to_a.join(',')
      if filter == "pending" or filter == "unpaid"
        invoice_status = (0..98).to_a.join(',')
      elsif filter == "charged"
        invoice_status = 99
      end
      # @subscriber_invoice_items = []
      # @subscriber_invoices = []
      @subscriber_bills = Bill.by_subscriber_full(@subscriber.id, invoice_status).paginate(:page => params[:bill_page] || 1, :per_page => 10)
      @subscriber_bills_total = Bill.by_subscriber_total(@subscriber.id, invoice_status).first.bills_total
      # @subscriber_bills = Bill.by_subscriber_full(@subscriber.id, invoice_status)
      # if !@subscriber_bills.empty?
      #   @subscriber_invoices = Invoice.by_bill_ids(@subscriber_bills.map(&:bill_id_).join(','))
      #   if !@subscriber_invoices.empty?
      #     @subscriber_invoice_items = InvoiceItem.by_invoice_ids(@subscriber_invoices.map(&:invoice_id_).join(','))
      #   end
      # end
      # search_bills = Bill.search do
      #   if filter == "pending" or filter == "unpaid"
      #     with(:invoice_status_id, 0..98)
      #   elsif filter == "charged"
      #     with :invoice_status_id, 99
      #   end
      #   with :subscriber_id, params[:id]
      #   data_accessor_for(Bill).include = [:invoice_status, {invoices: [:invoice_type, :invoice_operation, {invoice_items: :tax_type}]}]
      #   order_by :sort_id, :desc
      #   paginate :page => params[:page] || 1, :per_page => per_page || 10
      # end
      # @subscriber_bills = search_bills.results

      respond_to do |format|
       format.html # show.html.erb
       format.json { render json: @subscriber_bills }
       format.js
      end
    end

    def show_dropdowns(subscriber)
      #*** For modal dropdowns ***
      # _add_meter, _new_reading
      @reading = Reading.new
      # _add_meter, _change_meter, _quit_meter, _new_reading
      @meter_location = MeterLocation.all
      @billing_period = billing_periods_dropdown(subscriber.office_id, subscriber.billing_frequency_id)
      @reading_incidence = ReadingIncidenceType.all
      # _new_reading
      _projects, _oco = projects_dropdown
      @project_dropdown = !_oco ? Project.active_only : _projects
      @reading_type = ReadingType.single_manual_reading
      # _change_data_supply
      @street_types = []
      @towns = []
      @provinces = []
      @zipcodes = []
      @regions = []
      # _change_data_supply, _new_client_bank_account
      @countries = []
      # _new_client_bank_account
      @bank = []
      @bank_offices = []
      @bank_account_classes = []
      # modals in show
      @billing_periods_reading = BillingPeriod.readings_unbilled_by_subscriber(subscriber.id)
    end

    # GET /subscribers/new
    # GET /subscribers/new.json
    def new
      @breadcrumb = 'create'
      @subscriber = Subscriber.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subscriber }
      end
    end

    # GET /subscribers/1/edit
    def edit
      @subscriber = Subscriber.find(params[:id])
      @countries = Country.order(:name)
      @bank = banks_dropdown
      @bank_offices = bank_offices_dropdown
    end

    # POST /subscribers
    # POST /subscribers.json
    def create
      @contracting_request = ContractingRequest.find params[:contracting_request_id]
      if !@contracting_request.subscriber.nil?
        redirect_to contracting_request_path(@contracting_request), alert: I18n.t("ag2_gest.contracting_requests.show.error_subscriber_exits")
      else
        params_meter_details = params[:subscriber][:meter_details_attributes]["0"]
        params_readings = params[:subscriber][:readings_attributes]["0"]
        params[:subscriber].delete :meter_details_attributes
        params[:subscriber].delete :readings_attributes
        @billing_period = BillingPeriod.find(params_readings[:billing_period_id])
        @subscriber = Subscriber.new(params[:subscriber].except(:meter_code_input))
        @subscriber.assign_attributes(
          active: true,
          billing_frequency_id: @billing_period.billing_frequency_id,
          building: @contracting_request.subscriber_building,
          cadastral_reference: @contracting_request.water_supply_contract.try(:cadastral_reference),
          center_id: @contracting_request.subscriber_center_id,
          client_id: @contracting_request.water_supply_contract.client_id,
          # contract: ,
          # country_id: @contracting_request.subscriber_country_id,
          # ending_at: ,
          endowments: @contracting_request.water_supply_contract.try(:endowments),
          fiscal_id: @contracting_request.entity.fiscal_id,
          floor: @contracting_request.subscriber_floor,
          floor_office: @contracting_request.subscriber_floor_office,
          gis_id: @contracting_request.water_supply_contract.try(:gis_id),
          pub_record: @contracting_request.water_supply_contract.try(:pub_record),
          inhabitants: @contracting_request.water_supply_contract.try(:inhabitants),
          # name: @contracting_request.entity.try(:full_name),
          office_id: @contracting_request.project.try(:office).try(:id),
          # province_id: @contracting_request.subscriber_province_id,
          # region_id: @contracting_request.subscriber_region_id,
          remarks: @contracting_request.try(:water_supply_contract).try(:remarks),
          starting_at: @contracting_request.try(:water_supply_contract).try(:contract_date),
          street_directory_id: @contracting_request.subscriber_street_directory_id,
          # street_name: @contracting_request.subscriber_street_name,
          street_number: @contracting_request.subscriber_street_number,
          # street_type_id: @contracting_request.subscriber_street_type_id,
          subscriber_code: sub_next_no(@contracting_request.project.office_id),
          # town_id: @contracting_request.subscriber_town_id,
          zipcode_id: @contracting_request.subscriber_zipcode_id,
          tariff_scheme_id: @contracting_request.water_supply_contract.tariff_scheme_id,
          first_name: @contracting_request.entity.first_name,
          last_name: @contracting_request.entity.last_name,
          company: @contracting_request.entity.company,
          service_point_id: @contracting_request.service_point_id,
          contracting_request_id: @contracting_request.id,
          use_id: @contracting_request.water_supply_contract.use_id,
          deposit: @contracting_request.water_supply_contract.bill.invoices.first.invoice_items.where(subcode: "FIA").blank? ? 0 : @contracting_request.water_supply_contract.bill.invoices.first.invoice_items.where(subcode: "FIA").first.total,
          phone: @contracting_request.client_phone,
          cellular: @contracting_request.client_cellular,
          email: @contracting_request.client_email,
          fax: @contracting_request.client_fax,
          postal_first_name: @contracting_request.client.first_name,
          postal_last_name: @contracting_request.client.last_name,
          postal_company: @contracting_request.client.company,
          postal_street_directory_id: @contracting_request.client_street_directory_id,
          postal_street_type_id: @contracting_request.client_street_type_id,
          postal_street_name: @contracting_request.client_street_name,
          postal_street_number: @contracting_request.client_street_number,
          postal_building: @contracting_request.client_building,
          postal_floor: @contracting_request.client_floor,
          postal_floor_office: @contracting_request.client_floor_office,
          postal_zipcode_id: @contracting_request.client_zipcode_id,
          postal_town_id: @contracting_request.client_town_id,
          postal_province_id: @contracting_request.client_province_id,
          postal_region_id: @contracting_request.client_region_id,
          postal_country_id: @contracting_request.client_country_id,
          created_by: (current_user.id if !current_user.nil?)
        )
        if @subscriber.save
          @contracting_request.water_supply_contract.contracted_tariffs.update_all(:starting_at => @subscriber.starting_at)
          @subscriber.tariffs << @contracting_request.water_supply_contract.tariffs
          @subscriber.subscriber_tariffs.where(ending_at: nil).update_all(:starting_at => @subscriber.starting_at)
          if ServicePoint.find(@subscriber.service_point_id).subscribers.count == 1
            @subscriber.service_point.update_attributes(meter_id: @subscriber.meter_id, reading_sequence: @subscriber.reading_sequence, reading_variant: @subscriber.reading_variant, reading_route_id: @subscriber.reading_route_id)
          end
          billing_frequency = @billing_period.billing_frequency_id
          #lectura de retirada
        # if @contracting_request.contracting_request_type_id == ContractingRequestType::CHANGE_OWNERSHIP && @contracting_request.old_subscriber
        #     @reading = Reading.create(
        #       subscriber_id: @contracting_request.old_subscriber.id,
        #       project_id: @contracting_request.project_id,
        #       billing_period_id: params_readings[:billing_period_id],
        #       billing_frequency_id: billing_frequency,
        #       reading_type_id: ReadingType::RETIRADA,
        #       meter_id: @contracting_request.old_subscriber.meter_id,
        #       reading_route_id: @contracting_request.old_subscriber.reading_route_id,
        #       reading_sequence: @contracting_request.old_subscriber.reading_sequence,
        #       reading_variant:  @contracting_request.old_subscriber.reading_variant,
        #       reading_date: params_meter_details[:installation_date],
        #       reading_index: params_meter_details[:installation_reading],
        #       reading_index_1: @contracting_request.old_subscriber.readings.last.reading_index,
        #       reading_index_2: @contracting_request.old_subscriber.readings.last.reading_index_1,
        #       reading_1: @contracting_request.old_subscriber.readings.last,
        #       reading_2: @contracting_request.old_subscriber.readings.last.reading_1,
        #       created_by: (current_user.id if !current_user.nil?)
        #     )
        #   end
          # lectura de instalacion
          @reading = Reading.create(
            subscriber_id: @subscriber.id,
            service_point_id: @subscriber.service_point_id,
            coefficient: @subscriber.meter.shared_coefficient,
            project_id: @contracting_request.project_id,
            billing_period_id: params_readings[:billing_period_id],
            billing_frequency_id: billing_frequency,
            reading_type_id: ReadingType::INSTALACION,
            meter_id: @subscriber.meter_id,
            reading_route_id: @subscriber.reading_route_id,
            reading_sequence: @subscriber.reading_sequence,
            reading_variant:  @subscriber.reading_variant,
            reading_date: params_meter_details[:installation_date],
            reading_index: params_meter_details[:installation_reading],
            bill_id: @contracting_request.water_supply_contract.bill_id,
            created_by: (current_user.id if !current_user.nil?)
          )
          #<-- NEW MJ <--> SI A LA LECTURA LE GUARDA EL BILL_ID PORQUE NO GUARDAR EL READING_ID EN LA BILL
          @contracting_request.water_supply_contract.bill.update_attributes(reading_2_id: @reading.id)
          #NEW -->

          # CHANGE_OWNERS
          if @contracting_request.old_subscriber
            @contracting_request.old_subscriber.update_attributes(ending_at: Date.today, active: false, meter_id: nil, service_point_id: nil)
            if ServicePoint.find(@contracting_request.old_subscriber.service_point_id).subscribers.count == 1
              @contracting_request.old_subscriber.service_point.update_attributes(meter_id: nil)
            end
            # update meter details withdrawal
            @contracting_request.old_subscriber.meter_details.last.update_attributes(withdrawal_date: Date.today ,
                                                                withdrawal_reading: @contracting_request.old_subscriber.readings.last.reading_index)
          end
          # @meter_details = @subscriber.meter_details.build(params_meter_details)
          # @meter_details.assign_attributes(meter_id: @subscriber.meter_id)
          if @subscriber.meter.first_installation_date.blank?
            @subscriber.meter.update_attributes(first_installation_date: params_meter_details[:installation_date])
          end
          @meter_details = MeterDetail.new(
            meter_id: @subscriber.meter_id,
            subscriber_id: @subscriber.id,
            installation_date: params_meter_details[:installation_date],
            installation_reading: params_meter_details[:installation_reading],
            meter_location_id: params_meter_details[:meter_location_id],
            created_by: (current_user.id if !current_user.nil?)
          )
          @contracting_request.water_supply_contract.update_attributes(meter_id: @subscriber.meter_id)
          _client_bank_account = @contracting_request.client.client_bank_accounts.order(:starting_at)
          if !_client_bank_account.blank? and _client_bank_account.last.subscriber_id.nil? and _client_bank_account.last.ending_at.nil?
            @contracting_request.client.client_bank_accounts.where(ending_at: nil,subscriber_id: nil).last.update_attributes(subscriber_id: @subscriber.id)
          end
          if !_client_bank_account.blank? and _client_bank_account.last.subscriber_id == @subscriber.id and _client_bank_account.last.ending_at.nil?
            @contracting_request.client.client_bank_accounts.where(subscriber_id: @subscriber.id, ending_at: nil).last.update_attributes(ending_at: Date.today, updated_by: @contracting_request.created_by )
          end
          if @meter_details.save
            @contracting_request.status_control
            if @contracting_request.save
              @old_subscriber = @contracting_request.old_subscriber
              @contracting_request.water_supply_contract.update_attributes(subscriber_id: @subscriber.id, contract_date: @subscriber.starting_at) if @contracting_request.water_supply_contract
              @contracting_request.water_supply_contract.bill.update_attributes(subscriber_id: @subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
              ClientPayment.find_by_bill_id(@contracting_request.water_supply_contract.bill).update_attributes(subscriber_id: @subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bill
              @contracting_request.water_supply_contract.bailback_bill.update_attributes(subscriber_id: @old_subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bailback_bill
              ClientPayment.find_by_bill_id(@contracting_request.water_supply_contract.bailback_bill).update_attributes(subscriber_id: @old_subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.bailback_bill
              @contracting_request.water_supply_contract.unsubscribe_bill.update_attributes(subscriber_id: @old_subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.unsubscribe_bill
              ClientPayment.find_by_bill_id(@contracting_request.water_supply_contract.unsubscribe_bill).update_attributes(subscriber_id: @old_subscriber.id) if @contracting_request.water_supply_contract and @contracting_request.water_supply_contract.unsubscribe_bill

              response_hash = { subscriber: @subscriber }
              response_hash[:bill] = @contracting_request.water_supply_contract.bill
              response_hash[:contracting_request] = @contracting_request
              response_hash[:reading] = @reading
              response_hash[:water_supply_contract] = @contracting_request.water_supply_contract
              response_hash[:client_bank_accounts] = ClientBankAccount.where(subscriber_id: @subscriber.id).active.first
              respond_to do |format|
                format.json { render json: response_hash }
              end
            else
              respond_to do |format|
                format.json { render :json => { :errors => @subscriber.errors.as_json }, :status => 420 }
              end
            end
          else
            respond_to do |format|
              format.json { render :json => { :errors => "Meter detail error" }, :status => 420 }
            end
          end
        else
          respond_to do |format|
            format.json { render :json => { :errors => @subscriber.errors.as_json }, :status => 420 }
          end
        end
      end
    end

    # PUT /subscribers/1
    # PUT /subscribers/1.json
    def update
      @subscriber = Subscriber.find(params[:id])

      respond_to do |format|
        if @subscriber.update_attributes(params[:subscriber])
          format.html { redirect_to @subscriber, notice: t( 'activerecord.attributes.subscriber.successfully') }
          format.json { head :no_content }
        else
          @countries = Country.order(:name)
          @bank = banks_dropdown
          @bank_offices = bank_offices_dropdown
          format.html { render action: "edit" }
          format.json { render json: @subscriber.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /subscribers/1
    # DELETE /subscribers/1.json
    def destroy
      @subscriber = Subscriber.find(params[:id])
      @subscriber.destroy

      respond_to do |format|
        format.html { redirect_to subscribers_url }
        format.json { head :no_content }
      end
    end

    def popover
      @reading_incidence = ReadingIncidence.find(params[:id])
      respond_to do |format|
        format.html { redirect_to subscribers_url }
        format.json { head :no_content }
      end
    end

    def simple_bill
      @subscriber = Subscriber.find params[:id]
      period = BillingPeriod.find(params[:bills][:billing_period_id])
      bill_original = ''
      bill_void = ''
      @reading = @subscriber.readings.where(billing_period_id: params[:bills][:billing_period_id], reading_type_id: [ReadingType::INSTALACION, ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).last
      # payday_limit = params[:bills][:payday_limit].blank? ? @reading.billing_period.billing_starting_date : params[:bills][:payday_limit]
      # invoice_date = params[:bills][:invoice_date].blank? ? @reading.billing_period.billing_ending_date : params[:bills][:invoice_date]
      invoice_date = Date.today
      payday_limit = invoice_date + @subscriber.office.days_for_invoice_due_date
      # if !@reading.billing_period.billing_ending_date.blank? && !@reading.billing_period.billing_starting_date.blank?
      #   payday_limit = @reading.billing_period.billing_ending_date >= invoice_date ? @reading.billing_period.billing_ending_date : invoice_date + (@reading.billing_period.billing_ending_date - @reading.billing_period.billing_starting_date).days
      # end

      bills = Bill.service_by_project_period_subscriber(period.project_id, period.id, @subscriber.id)
      bills.each do |b|
        if b.bill_operation == 1
          bill_original = 1
        end
        if b.bill_operation == 2
          bill_void = 2
        end
      end
      if bill_original == '' && bill_void == ''
        @bill = @reading.generate_bill(bill_next_no(@reading.project),current_user.try(:id),1,payday_limit,invoice_date)
      end
      if bill_original == 1 && bill_void == 2
        @bill = @reading.generate_bill(bill_next_no(@reading.project),current_user.try(:id),3,payday_limit,invoice_date)
      end
      if (bill_original == 1 && bill_void == '') || (bill_original == '' && bill_void == 2)
        return false
      end
      Sunspot.index! [@bill] unless @bill.blank?

      @subscriber_readings = Reading.by_subscriber_full(params[:id]).paginate(:page => params[:page] || 1, :per_page => 10)
      invoice_status = (0..99).to_a.join(',')
      @subscriber_bills = Bill.by_subscriber_full(params[:id], invoice_status).paginate(:page => params[:page] || 1, :per_page => 10)

      respond_to do |format|
        format.json { render json: @subscriber_bills }
        format.js { }
      end
    end

    # subscriber report
    def subscriber_report
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Subscriber.count
      end

      @subscriber_report = @search.results

      if !@subscriber_report.blank?
        title = t("activerecord.models.subscriber.few")
        @to = formatted_date(@subscriber_report.first.created_at)
        @from = formatted_date(@subscriber_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end


     # subscriber tec report
    def subscriber_tec_report
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Subscriber.count
      end

      @subscriber_tec_report = @search.results

      if !@subscriber_tec_report.blank?
        title = t("activerecord.models.subscriber.few")
        @to = formatted_date(@subscriber_tec_report.first.created_at)
        @from = formatted_date(@subscriber_tec_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

     # subscriber eco report
    def subscriber_eco_report
      manage_filter_state
      subscriber_code = params[:SubscriberCode]
      service_point = params[:ServicePoint]
      meter = params[:Meter]
      billing_frequency = params[:BillingFrequency]
      tariff_type = params[:TariffType]
      letter = params[:letter]
      # OCO
      init_oco if !session[:organization]

      # If inverse no search is required
      subscriber_code = !subscriber_code.blank? && subscriber_code[0] == '%' ? inverse_no_search(subscriber_code) : subscriber_code

      @search = Subscriber.search do
        fulltext params[:search]
        if session[:office] != '0'
          with :office_id, session[:office]
        end
        if !letter.blank? && letter != "%"
          with(:full_name).starting_with(letter)
        end
        if !subscriber_code.blank?
          if subscriber_code.class == Array
            with :subscriber_code, subscriber_code
          else
            with(:subscriber_code).starting_with(subscriber_code)
          end
        end
        if !service_point.blank?
          with :service_point_id, service_point
        end
        if !meter.blank?
          with :meter_id, meter
        end
        if !billing_frequency.blank?
          with :billing_frequency_id, billing_frequency
        end
        if !tariff_type.blank?
          with :tariff_type_id, tariff_type
        end
        order_by :sort_no, :asc
        paginate :page => params[:page] || 1, :per_page => Subscriber.count
      end

      @subscriber_eco_report = @search.results

      if !@subscriber_eco_report.blank?
        title = t("activerecord.models.subscriber.few")
        @to = formatted_date(@subscriber_eco_report.first.created_at)
        @from = formatted_date(@subscriber_eco_report.last.created_at)
        respond_to do |format|
          # Render PDF
          format.pdf { send_data render_to_string,
                       filename: "#{title}_#{@from}-#{@to}.pdf",
                       type: 'application/pdf',
                       disposition: 'inline' }
        end
      end
    end

    private

    def towns_dropdown
      Town.order('towns.name').joins(:province) \
          .select("towns.id, CONCAT(towns.name, ' (', provinces.name, ')') to_label_")
    end

    def provinces_dropdown
      Province.order('provinces.name').joins(:region)
              .select("provinces.id, CONCAT(provinces.name, ' (', regions.name, ')') to_label_")
    end

    def zipcodes_dropdown
      Zipcode.order(:zipcode).joins(:town, :province) \
             .select("zipcodes.id, CONCAT(zipcodes.zipcode, ' - ', towns.name, ' (', provinces.name, ')') to_label_")
    end

    def regions_dropdown
      Region.order('regions.name').joins(:country) \
            .select("regions.id, CONCAT(regions.name, ' (', countries.name, ')') to_label_")
    end

    def countries_dropdown
      Country.order(:name) \
             .select("id, CONCAT(code, ' ', name) to_label_")
    end

    def street_types_dropdown
      StreetType.order(:street_type_code) \
                .select("id, CONCAT(street_type_code, ' (', street_type_description, ')') to_label_")
    end

    def banks_dropdown
      Bank.order(:code) \
          .select("id, CONCAT(code, ' ', name) to_label_")
    end

    def bank_offices_dropdown
      BankOffice.order('bank_offices.bank_id, bank_offices.code').joins(:bank)
                .select("bank_offices.id, CONCAT(bank_offices.code, ' ', bank_offices.name, ' (', banks.code, ')') to_label_")
    end

    def bank_account_classes_dropdown
      BankAccountClass.order(:name) \
                      .select("id, name to_label_")
    end

    def billing_periods_dropdown(o, f)
      if (!o.blank? && !f.blank?)
        billing_periods_by_office_and_frequency(o, f)
      elsif (!o.blank? && f.blank?)
        billing_periods_by_office(o)
      elsif (o.blank? && !f.blank?)
        billing_periods_by_frequency(f)
      else
        BillingPeriod.by_period_desc
      end
    end

    def billing_periods_by_office_and_frequency(o, f)
      BillingPeriod.belongs_to_office_and_frequency(o, f)
    end

    def billing_periods_by_office(o)
      BillingPeriod.belongs_to_office(o)
    end

    def billing_periods_by_frequency(f)
      BillingPeriod.belongs_to_frequency(f)
    end

    def read_billing_periods
      @subscriber.readings.order("billing_period_id DESC").select{|r| [ReadingType::INSTALACION, ReadingType::NORMAL, ReadingType::OCTAVILLA, ReadingType::RETIRADA, ReadingType::AUTO].include? r.reading_type_id and r.billable?}.map(&:billing_period).uniq
    end

    def projects_dropdown
      _projects = nil
      _oco = false
      if session[:office] != '0'
        _projects = Project.active_only.where(office_id: session[:office].to_i)
        _oco = true
      elsif session[:company] != '0'
        _projects = Project.active_only.where(company_id: session[:company].to_i)
        _oco = true
      elsif session[:organization] != '0'
        _projects = Project.active_only.where(organization_id: session[:organization].to_i)
        _oco = true
      end
      return _projects, _oco
    end

    def banks_array
      _banks = banks_dropdown
      _array = []
      _banks.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def bank_offices_array
      _bank_offices = bank_offices_dropdown
      _array = []
      _bank_offices.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def bank_account_classes_array
      _bac = bank_account_classes_dropdown
      _array = []
      _bac.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def towns_array
      _towns = towns_dropdown
      _array = []
      _towns.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def provinces_array
      _provinces = provinces_dropdown
      _array = []
      _provinces.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def zipcodes_array
      _zipcodes = zipcodes_dropdown
      _array = []
      _zipcodes.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def regions_array
      _regions = regions_dropdown
      _array = []
      _regions.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def country_array
      _country = countries_dropdown
      _array = []
      _country.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def street_types_array
      _street_types = street_types_dropdown
      _array = []
      _street_types.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def reports_array()
      _array = []
      _array = _array << t("ag2_gest.subscribers.report.subscriber_report")
      _array = _array << t("ag2_gest.subscribers.report.subscriber_tec_report")
      _array = _array << t("ag2_gest.subscribers.report.subscriber_eco_report")
      _array
    end

    def void_bill(bill)
      bill_cancel = bill.dup
      bill_cancel.bill_date = Date.today
      bill_cancel.bill_no = bill_next_no(bill.project_id)
      if bill_cancel.save
        bill.invoices.each do |invoice|
          new_invoice = invoice.dup
          new_invoice.invoice_date = Date.today
          new_invoice.payday_limit = nil
          new_invoice.invoice_no = void_invoice_next_no(invoice.biller_id, bill.project.office_id)
          new_invoice.bill_id = bill_cancel.id
          new_invoice.invoice_operation_id = InvoiceOperation::CANCELATION
          new_invoice.original_invoice_id = invoice.id
          new_invoice.save
          invoice.invoice_items.each do |item|
            new_item = item.dup
            new_item.invoice_id = new_invoice.id
            new_item.price = new_item.price * -1
            new_item.save
          end
          _i = Invoice.find(new_invoice.id)
          _i.totals = _i.total
          _i.save
        end
        bill.reading.update_attributes(bill_id: nil)
        return bill_cancel
      else
        return false
      end
    end

    def setup_no(no)
      no = no[0] != '%' ? '%' + no : no
      no = no[no.length-1] != '%' ? no + '%' : no
    end

    def inverse_no_search(no)
      _numbers = []
      Subscriber.where('subscriber_code LIKE ?', "#{no}").each do |i|
        _numbers = _numbers << i.subscriber_code
      end
      _numbers = _numbers.blank? ? no : _numbers
    end

    def inverse_meter_search(meter)
      _numbers = []
      no = setup_no(meter)
      Meter.where('meter_code LIKE ?', "#{no}").first(1000).each do |i|
        _numbers = _numbers << i.meter_code
      end
      _numbers = _numbers.blank? ? meter : _numbers
    end

    def inverse_street_name_search(supply_address)
      _numbers = []
      no = setup_no(supply_address)
      SubscriberSupplyAddress.where('supply_address LIKE ?', "#{no}").first(1000).each do |i|
        _numbers = _numbers << i.supply_address
      end
      _numbers = _numbers.blank? ? supply_address : _numbers
    end

    def service_points_dropdown
      if session[:office] != '0'
        ServicePoint.where(office_id: session[:office]).order(:street_directory_id)
      elsif session[:company] != '0'
        ServicePoint.where(company_id: session[:company]).order(:street_directory_id)
      elsif session[:organization] != '0'
        ServicePoint.where(organization_id: session[:organization]).order(:street_directory_id)
      else
        ServicePoint.order(:street_directory_id)
      end
    end

    def meters_dropdown
      if session[:office] != '0'
        Meter.where(office_id: session[:office]).order(:meter_code)
      elsif session[:company] != '0'
        Meter.where(company_id: session[:company]).order(:meter_code)
      else
        Meter.order(:meter_code)
      end
    end

    def meter_locations_array
      _d = MeterLocation.all
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.name]
      end
      _array
    end

    def billing_periods_array(subscriber)
      _d = billing_periods_dropdown(subscriber.office_id, subscriber.billing_frequency_id)
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def billing_period_readings_array(subscriber)
      _d = BillingPeriod.readings_unbilled_by_subscriber(subscriber.id)
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.to_label_]
      end
      _array
    end

    def reading_incidences_array
      _d = ReadingIncidenceType.all
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def reading_types_array
      _d = ReadingType.single_manual_reading
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def projects_array
      _projects, _oco = projects_dropdown
      _d = !_oco ? Project.active_only : _projects
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def billable_concepts_available_array(s)
      _bc = []
      a = SubscriberTariff.availables_to_subscriber(s)
      a.each do |sta|
         _bc = _bc << sta.tariff.billable_item.billable_concept_id
      end
      _d = BillableItem.with_tariff(s.tariffs.first.billable_item.project_id, _bc.blank? ? "" : _bc)
      _array = []
      _d.each do |i|
        _array = _array << [i.id, i.to_label_biller]
      end
      _array
    end

    def manage_filter_state_show
      if params[:ifilter_show]
        session[:ifilter_show] = params[:ifilter_show]
      elsif session[:ifilter_show]
        params[:ifilter_show] = session[:ifilter_show]
      end
      if params[:ifilter_show_tariff]
        session[:ifilter_show_tariff] = params[:ifilter_show_tariff]
      elsif session[:ifilter_show_tariff]
        params[:ifilter_show_tariff] = session[:ifilter_show_tariff]
      end
    end

    # Keeps filter state
    def manage_filter_state
      # ifilter
      if params[:ifilter]
        session[:ifilter] = params[:ifilter]
      elsif session[:ifilter]
        params[:ifilter] = session[:ifilter]
      end
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
      end
      # subscriber_code
      if params[:SubscriberCode]
        session[:SubscriberCode] = params[:SubscriberCode]
      elsif session[:SubscriberCode]
        params[:SubscriberCode] = session[:SubscriberCode]
      end
      # street_name
      if params[:StreetName]
        session[:StreetName] = params[:StreetName]
      elsif session[:StreetName]
        params[:StreetName] = session[:StreetName]
      end
      # meter
      if params[:Meter]
        session[:Meter] = params[:Meter]
      elsif session[:Meter]
        params[:Meter] = session[:Meter]
      end
      # caliber
      if params[:Caliber]
        session[:Caliber] = params[:Caliber]
      elsif session[:Caliber]
        params[:Caliber] = session[:Caliber]
      end
      # use
      if params[:Use]
        session[:Use] = params[:Use]
      elsif session[:Use]
        params[:Use] = session[:Use]
      end
      # tariff_type
      if params[:TariffType]
        session[:TariffType] = params[:TariffType]
      elsif session[:TariffType]
        params[:TariffType] = session[:TariffType]
      end
      # letter
      if params[:letter]
        if params[:letter] == '%'
          session[:letter] = nil
          params[:letter] = nil
        else
          session[:letter] = params[:letter]
        end
      elsif session[:letter]
        params[:letter] = session[:letter]
      end
    end

    def su_remove_filters
      params[:search] = ""
      params[:SubscriberCode] = ""
      params[:StreetName] = ""
      params[:Meter] = ""
      params[:Caliber] = ""
      params[:Use] = ""
      params[:TariffType] = ""
      return " "
    end

    def su_restore_filters
      params[:search] = session[:search]
      params[:SubscriberCode] = session[:SubscriberCode]
      params[:StreetName] = session[:StreetName]
      params[:Meter] = session[:Meter]
      params[:Caliber] = session[:Caliber]
      params[:Use] = session[:Use]
      params[:TariffType] = session[:TariffType]
    end
  end
end
