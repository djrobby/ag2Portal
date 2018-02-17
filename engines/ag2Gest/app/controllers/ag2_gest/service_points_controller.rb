require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ServicePointsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column
    skip_load_and_authorize_resource :only => [ :update_offices_textfield_from_company,
                                                :update_province_textfield_from_zipcode,
                                                :create,
                                                :update_province_textfield_from_street_directory,
                                                :serpoint_generate_no,
                                                :sp_find_meter,
                                                :install_meter,
                                                :withdrawal_meter,
                                                :change_meter]
    #
    # Meter change
    #
    def change_meter
      @service_point = ServicePoint.find(params[:id])
      @billing_period = BillingPeriod.find(params[:reading][:q_billing_period_id])
      @meter_w = @service_point.meter rescue nil
      @subscriber_w = @meter_w.subscribers.activated
      project = params[:reading][:project_id] || @billing_period.project_id
      su = []
      save_all_ok = false

      #Create Reading
      if !@subscriber_w.blank?
        coefi = @meter_w.is_shared? ? @meter_w.shared_coefficient : @subscriber_w.count
        @subscriber_w.each do |s|
          if @meter_w.id == s.meter_id
            @reading_q = Reading.new( project_id: project,
                         billing_period_id: params[:reading][:q_billing_period_id],
                         reading_type_id: ReadingType::RETIRADA, #ReadingType Withdrawal
                         meter_id: @meter_w.id,
                         subscriber_id: s.id,
                         service_point_id: @service_point.id,
                         coefficient: coefi,
                         reading_date: params[:reading][:q_reading_date],
                         reading_index: params[:reading][:q_reading_index]
                      )
            rdg_1 = set_reading_1_to_reading(s,@meter_w,@billing_period)
            rdg_2 = set_reading_2_to_reading(s,@meter_w,@billing_period)
            @reading_q.reading_1 = rdg_1
            @reading_q.reading_index_1 = rdg_1.try(:reading_index)
            @reading_q.reading_2 = rdg_2
            @reading_q.reading_index_2 = rdg_2.try(:reading_index)
            @reading_q.reading_sequence = s.reading_sequence
            @reading_q.reading_variant = s.reading_variant
            @reading_q.reading_route_id = s.reading_route_id
            @reading_q.billing_frequency_id = @billing_period.try(:billing_frequency_id)
            @reading_q.created_by = current_user.id if !current_user.nil?

            @reading_q.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:q_incidence_type_ids])

            # Update MeterDetail associated
            @meter_detail_w = MeterDetail.where(subscriber_id: s.id, meter_id: @meter_w.id, withdrawal_date: nil).first
            @meter_detail_w.withdrawal_date = params[:reading][:q_reading_date] unless @meter_detail_w.blank?
            @meter_detail_w.withdrawal_reading = params[:reading][:q_reading_index] unless @meter_detail_w.blank?
            # Update Meter last_withdrawal_date if appropiate
            if @meter_w.shared_coefficient == 0 && (@meter_w.last_withdrawal_date.blank? || @meter_detail_w.withdrawal_date > @meter_w.last_withdrawal_date)
              @meter_w.last_withdrawal_date = @meter_detail_w.withdrawal_date
            end

            # Remove meter from subscriber
            # s.meter_id = nil
            # Try to save everything
            if (@meter_detail_w.save and @reading_q.save)
              s.update_attributes(active: false, meter_id: nil)
              s.service_point.update_attributes(meter_id: nil)
              su << s
              save_all_ok = true
              if @meter_w.last_withdrawal_date != @meter_w.last_withdrawal_date_was # last_withdrawal_date has changed, save it
                if !@meter_w.save
                  save_all_ok = false
                end
              end
            else
              save_all_ok = false
              break
            end
          end # @meter_w.id == s.meter_id
        end # @subscriber_w.each do |s|
      else
        @reading_q = Reading.new( project_id: project,
                       billing_period_id: params[:reading][:q_billing_period_id],
                       reading_type_id: ReadingType::RETIRADA, #ReadingType Withdrawal
                       meter_id: @meter_w.id,
                       subscriber_id: nil,
                       service_point_id: @service_point.id,
                       coefficient: @meter_w.shared_coefficient,
                       reading_date: params[:reading][:q_reading_date],
                       reading_index: params[:reading][:q_reading_index]
                    )

        rdg_1 = set_reading_1_to_reading(nil,@meter_w,@billing_period)
        rdg_2 = set_reading_2_to_reading(nil,@meter_w,@billing_period)
        @reading_q.reading_1 = rdg_1
        @reading_q.reading_index_1 = rdg_1.try(:reading_index)
        @reading_q.reading_2 = rdg_2
        @reading_q.reading_index_2 = rdg_2.try(:reading_index)
        @reading_q.reading_sequence = @service_point.reading_sequence
        @reading_q.reading_variant = @service_point.reading_variant
        @reading_q.reading_route_id = @service_point.reading_route_id
        @reading_q.billing_frequency_id = @billing_period.try(:billing_frequency_id)
        @reading_q.created_by = current_user.id if !current_user.nil?
        @reading_q.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:q_incidence_type_ids])

        # Update MeterDetail associated
        @meter_detail_w = MeterDetail.where(subscriber_id: nil, meter_id: @meter_w.id, withdrawal_date: nil).first
        @meter_detail_w.withdrawal_date = params[:reading][:q_reading_date] unless @meter_detail_w.blank?
        @meter_detail_w.withdrawal_reading = params[:reading][:q_reading_index] unless @meter_detail_w.blank?
        # Update Meter last_withdrawal_date if appropiate
        if @meter_w.shared_coefficient == 0 && (@meter_w.last_withdrawal_date.blank? || @meter_detail_w.withdrawal_date > @meter_w.last_withdrawal_date)
          @meter_w.last_withdrawal_date = @meter_detail_w.withdrawal_date
        end

        # Try to save everything
        if (@meter_detail_w.save and @reading_q.save)
          save_all_ok = true
          @service_point.update_attributes(meter_id: nil)
          if @meter_w.last_withdrawal_date != @meter_w.last_withdrawal_date_was # last_withdrawal_date has changed, save it
            if !@meter_w.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end
      end
      redirect_to @service_point, alert: t('activerecord.attributes.subscriber.quit_meter_failure') and return if !save_all_ok


      # Install meter--
      @meter_a = Meter.find(params[:reading][:meter_id])
      @billing_period_a = BillingPeriod.find(params[:reading][:a_billing_period])
      # @subscriber_a = @service_point.subscribers.availables

      #Create Reading
      if !su.blank?
        coefi = @meter_a.is_shared? ? @meter_a.shared_coefficient : su.count
        su.each do |s|
          @reading_a = Reading.new( project_id: project,
                         billing_period_id: params[:reading][:a_billing_period],
                         reading_type_id: ReadingType::INSTALACION, #ReadingType Withdrawal
                         meter_id: @meter_a.id,
                         subscriber_id: s.id,
                         service_point_id: @service_point.id,
                         coefficient: coefi,
                         reading_date: params[:reading][:a_reading_date],
                         reading_index: params[:reading][:a_reading_index]
                      )
          @reading_a.reading_1 = nil
          @reading_a.reading_index_1 = nil
          @reading_a.reading_2 = nil
          @reading_a.reading_index_2 = nil
          @reading_a.reading_sequence = s.reading_sequence
          @reading_a.reading_variant = s.reading_variant
          @reading_a.reading_route_id = s.reading_route_id
          @reading_a.billing_frequency_id = @billing_period_a.try(:billing_frequency_id)
          @reading_a.created_by = current_user.id if !current_user.nil?
          @reading_a.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:a_incidence_type_ids])
          # #Create MeterDetail
          @meter_detail_a = MeterDetail.new( meter_id: @meter_a.id,
                                             subscriber_id: s.id,
                                             installation_date:  params[:reading][:a_reading_date],
                                             installation_reading: params[:reading][:a_reading_index],
                                             meter_location_id: params[:reading][:meter_location_id],
                                             withdrawal_date: nil,
                                             withdrawal_reading: nil )
          # Update Meter first_installation_date if appropiate
          if @meter_a.first_installation_date.blank? || @meter_detail_a.installation_date < @meter_a.first_installation_date
            @meter_a.first_installation_date = @meter_detail_a.installation_date
          end
          if !@meter_w.master_meter_id.blank?
            @meter_a.master_meter_id = @meter_w.master_meter_id
          end

          # Assign meter
          # s.meter_id = @meter_a.id
          # Try to save everything
          if (@meter_detail_a.save and @reading_a.save)
            s.update_attributes(active: true, meter_id: @meter_a.id)
            s.service_point.update_attributes(meter_id: @meter_a.id)
            save_all_ok = true
            if @meter_a.first_installation_date != @meter_a.first_installation_date_was # first_installation_date has changed, save it
              if !@meter_a.save
                save_all_ok = false
              end
            end
          else
            save_all_ok = false
            break
          end
        end # su.each do |s|
      else
        @reading_a = Reading.new( project_id: project,
                      billing_period_id: params[:reading][:a_billing_period],
                      reading_type_id: ReadingType::INSTALACION, #ReadingType Withdrawal
                      meter_id: @meter_a.id,
                      subscriber_id: nil,
                      service_point_id: @service_point.id,
                      reading_date: params[:reading][:a_reading_date],
                      reading_index: params[:reading][:a_reading_index]
                    )
        @reading_a.reading_1 = nil
        @reading_a.reading_index_1 = nil
        @reading_a.reading_2 = nil
        @reading_a.reading_index_2 = nil
        @reading_a.reading_sequence = @service_point.reading_sequence
        @reading_a.reading_variant = @service_point.reading_variant
        @reading_a.reading_route_id = @service_point.reading_route_id
        @reading_a.billing_frequency_id = @billing_period_a.try(:billing_frequency_id)
        @reading_a.created_by = current_user.id if !current_user.nil?
        @reading_a.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:a_incidence_type_ids])
        # #Create MeterDetail
        @meter_detail_a = MeterDetail.new( meter_id: @meter_a.id,
                                           subscriber_id: nil,
                                           installation_date:  params[:reading][:a_reading_date],
                                           installation_reading: params[:reading][:a_reading_index],
                                           meter_location_id: params[:reading][:meter_location_id],
                                           withdrawal_date: nil,
                                           withdrawal_reading: nil )
        # Update Meter first_installation_date if appropiate
        if @meter_a.first_installation_date.blank? || @meter_detail_a.installation_date < @meter_a.first_installation_date
          @meter_a.first_installation_date = @meter_detail_a.installation_date
        end
        if !@meter_w.master_meter_id.blank?
          @meter_a.master_meter_id = @meter_w.master_meter_id
        end
        # Try to save everything
        if (@meter_detail_a.save and @reading_a.save)
          save_all_ok = true
          @reading_a.update_attributes(coefficient: @meter_a.shared_coefficient)
          @service_point.update_attributes(meter_id: @meter_a.id)
          if @meter_a.first_installation_date != @meter_a.first_installation_date_was # first_installation_date has changed, save it
            if !@meter_a.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end
      end # !su.blank?

      respond_to do |format|
        if save_all_ok
          format.html { redirect_to @service_point, notice: t('activerecord.attributes.subscriber.add_meter_successful') }
          format.json { render json: @reading_a, status: :created, location: @reading_a }
        else
          format.html { redirect_to @service_point, alert: t('activerecord.attributes.subscriber.add_meter_failure') }
          format.json { render json: @reading_a.errors, status: :unprocessable_entity }
        end
      end
    end

    #
    # Meter installation
    #
    def install_meter
      @service_point = ServicePoint.find(params[:id])
      @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])
      @meter = Meter.find params[:reading][:meter_id] rescue nil
      @subscriber = @service_point.subscribers.deactivated
      project = params[:reading][:project_id] || @billing_period.project_id
      save_all_ok = false

      #Create Reading
      if !@subscriber.blank?
        coefi = @meter.is_shared? ? @meter.shared_coefficient : @subscriber.count
        @subscriber.each do |s|
          @reading = Reading.new( project_id: project,
                       billing_period_id: params[:reading][:billing_period_id],
                       reading_type_id: ReadingType::INSTALACION, #ReadingType Withdrawal
                       meter_id: @meter.id,
                       subscriber_id: s.id,
                       service_point_id: @service_point.id,
                       coefficient: coefi,
                       reading_date: params[:reading][:reading_date],
                       reading_index: params[:reading][:reading_index]
                    )
          @reading.reading_1 = nil
          @reading.reading_index_1 = nil
          @reading.reading_2 = nil
          @reading.reading_index_2 = nil
          @reading.reading_sequence = s.reading_sequence
          @reading.reading_variant = s.reading_variant
          @reading.reading_route_id = s.reading_route_id
          @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
          @reading.created_by = current_user.id if !current_user.nil?

          @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:incidence_type_ids])

          # #Create MeterDetail
          @meter_detail = MeterDetail.new( meter_id: @meter.id,
                                           subscriber_id: s.id,
                                           installation_date:  params[:reading][:reading_date],
                                           installation_reading: params[:reading][:reading_index],
                                           meter_location_id: params[:reading][:meter_location_id],
                                           withdrawal_date: nil,
                                           withdrawal_reading: nil )
          # Update Meter first_installation_date if appropiate
          if @meter.first_installation_date.blank? || @meter_detail.installation_date < @meter.first_installation_date
            @meter.first_installation_date = @meter_detail.installation_date
          end
          # Assign meter
          # Try to save everything
          if (@meter_detail.save and @reading.save)
            s.update_attributes(active: true, meter_id: @meter.id)
            s.service_point.update_attributes(meter_id: @meter.id)
            save_all_ok = true
            if @meter.first_installation_date != @meter.first_installation_date_was # first_installation_date has changed, save it
              if !@meter.save
                save_all_ok = false
              end
            end
          else
            save_all_ok = false
          end
        end
      else
        @reading = Reading.new( project_id: project,
                      billing_period_id: params[:reading][:billing_period_id],
                      reading_type_id: ReadingType::INSTALACION, #ReadingType Withdrawal
                      meter_id: @meter.id,
                      subscriber_id: nil,
                      service_point_id: @service_point.id,
                      reading_date: params[:reading][:reading_date],
                      reading_index: params[:reading][:reading_index]
                    )
        @reading.reading_1 = nil
        @reading.reading_index_1 = nil
        @reading.reading_2 = nil
        @reading.reading_index_2 = nil
        @reading.reading_sequence = @service_point.reading_sequence
        @reading.reading_variant = @service_point.reading_variant
        @reading.reading_route_id = @service_point.reading_route_id
        @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
        @reading.created_by = current_user.id if !current_user.nil?
        @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:incidence_type_ids])
        # #Create MeterDetail
        @meter_detail = MeterDetail.new( meter_id: @meter.id,
                                         subscriber_id: nil,
                                         installation_date:  params[:reading][:reading_date],
                                         installation_reading: params[:reading][:reading_index],
                                         meter_location_id: params[:reading][:meter_location_id],
                                         withdrawal_date: nil,
                                         withdrawal_reading: nil )
        # Update Meter first_installation_date if appropiate
        if @meter.first_installation_date.blank? || @meter_detail.installation_date < @meter.first_installation_date
          @meter.first_installation_date = @meter_detail.installation_date
        end
        # Try to save everything
        if (@meter_detail.save and @reading.save)
          @reading.update_attributes(coefficient: @meter.shared_coefficient)
          @service_point.update_attributes(meter_id: @meter.id)
          save_all_ok = true
          if @meter.first_installation_date != @meter.first_installation_date_was # first_installation_date has changed, save it
            if !@meter.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end
      end

      respond_to do |format|
        if save_all_ok
          format.html { redirect_to @service_point, notice: t('activerecord.attributes.subscriber.add_meter_successful') }
          format.json { render json: @reading, status: :created, location: @reading }
        else
          format.html { redirect_to @service_point, alert: t('activerecord.attributes.subscriber.add_meter_failure') }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end
    end

    #
    # Meter withdrawal
    #
    def withdrawal_meter
      @service_point = ServicePoint.find(params[:id])
      @billing_period = BillingPeriod.find(params[:reading][:billing_period_id])
      @meter = @service_point.meter rescue nil
      @subscriber = @meter.subscribers.activated
      project = params[:reading][:project_id] || @billing_period.project_id
      save_all_ok = false

      #Create Reading
      if !@subscriber.blank?
        coefi = @meter.is_shared? ? @meter.shared_coefficient : @subscriber.count
        @subscriber.each do |s|
          if @meter.id == s.meter_id
            @reading = Reading.new( project_id: project,
                         billing_period_id: params[:reading][:billing_period_id],
                         reading_type_id: ReadingType::RETIRADA, #ReadingType Withdrawal
                         meter_id: @meter.id,
                         subscriber_id: s.id,
                         service_point_id:@service_point.id,
                         coefficient: coefi,
                         reading_date: params[:reading][:reading_date],
                         reading_index: params[:reading][:reading_index]
                      )

            rdg_1 = set_reading_1_to_reading(s,@meter,@billing_period)
            rdg_2 = set_reading_2_to_reading(s,@meter,@billing_period)
            @reading.reading_1 = rdg_1
            @reading.reading_index_1 = rdg_1.try(:reading_index)
            @reading.reading_2 = rdg_2
            @reading.reading_index_2 = rdg_2.try(:reading_index)
            @reading.reading_sequence = s.reading_sequence
            @reading.reading_variant = s.reading_variant
            @reading.reading_route_id = s.reading_route_id
            @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
            @reading.created_by = current_user.id if !current_user.nil?

            @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:incidence_type_ids])

            # Update MeterDetail associated
            @meter_detail = MeterDetail.where(subscriber_id: s.id, meter_id: @meter.id, withdrawal_date: nil).first
            @meter_detail.withdrawal_date = params[:reading][:reading_date] unless @meter_detail.blank?
            @meter_detail.withdrawal_reading = params[:reading][:reading_index] unless @meter_detail.blank?
            # Update Meter last_withdrawal_date if appropiate
            if @meter.shared_coefficient == 0 && (@meter.last_withdrawal_date.blank? || @meter_detail.withdrawal_date > @meter.last_withdrawal_date)
              @meter.last_withdrawal_date = @meter_detail.withdrawal_date
            end

            # Try to save everything
            if (@meter_detail.save and @reading.save)
              s.update_attributes(active: false, meter_id: nil)
              s.service_point.update_attributes(meter_id: nil)
              save_all_ok = true
              if @meter.last_withdrawal_date != @meter.last_withdrawal_date_was # first_installation_date has changed, save it
                if !@meter.save
                  save_all_ok = false
                end
              end
            else
              save_all_ok = false
            end
          end
        end
      else
        @reading = Reading.new( project_id: project,
                       billing_period_id: params[:reading][:billing_period_id],
                       reading_type_id: ReadingType::RETIRADA, #ReadingType Withdrawal
                       meter_id: @meter.id,
                       subscriber_id: nil,
                       service_point_id:@service_point.id,
                       coefficient: @meter.shared_coefficient,
                       reading_date: params[:reading][:reading_date],
                       reading_index: params[:reading][:reading_index]
                    )

        rdg_1 = set_reading_1_to_reading(nil,@meter,@billing_period)
        rdg_2 = set_reading_2_to_reading(nil,@meter,@billing_period)
        @reading.reading_1 = rdg_1
        @reading.reading_index_1 = rdg_1.try(:reading_index)
        @reading.reading_2 = rdg_2
        @reading.reading_index_2 = rdg_2.try(:reading_index)
        @reading.reading_sequence = @service_point.reading_sequence
        @reading.reading_variant = @service_point.reading_variant
        @reading.reading_route_id = @service_point.reading_route_id
        @reading.billing_frequency_id = @billing_period.try(:billing_frequency_id)
        @reading.created_by = current_user.id if !current_user.nil?

        @reading.reading_incidence_types = ReadingIncidenceType.find_all_by_id(params[:incidence_type_ids])
        # Update MeterDetail associated
        @meter_detail = MeterDetail.where(subscriber_id: nil, meter_id: @meter.id, withdrawal_date: nil).first
        @meter_detail.withdrawal_date = params[:reading][:reading_date] unless @meter_detail.blank?
        @meter_detail.withdrawal_reading = params[:reading][:reading_index] unless @meter_detail.blank?
        # Update Meter last_withdrawal_date if appropiate
        if @meter.shared_coefficient == 0 && (@meter.last_withdrawal_date.blank? || @meter_detail.withdrawal_date > @meter.last_withdrawal_date)
          @meter.last_withdrawal_date = @meter_detail.withdrawal_date
        end

        # Try to save everything
        if (@meter_detail.save and @reading.save)
          save_all_ok = true
          @service_point.update_attributes(meter_id: nil)
          if @meter.last_withdrawal_date != @meter.last_withdrawal_date_was # first_installation_date has changed, save it
            if !@meter.save
              save_all_ok = false
            end
          end
        else
          save_all_ok = false
        end
      end

      respond_to do |format|
        if save_all_ok
          format.html { redirect_to @service_point, notice: t('activerecord.attributes.subscriber.quit_meter_successful') }
          format.json { render json: @reading, status: :created, location: @reading }
        else
          format.html { redirect_to @service_point, alert: t('activerecord.attributes.subscriber.quit_meter_failure') }
          format.json { render json: @reading.errors, status: :unprocessable_entity }
        end
      end
    end

    # Update province text field at view from town select
    def update_offices_textfield_from_company

      if params[:id] == "0"
        @offices = []
      else
        @offices = Company.find(params[:id]).offices
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @offices }
      end
    end

    # Update town, province, region and country text fields at view from zip code select
    def update_province_textfield_from_zipcode

      if params[:id] == "0"
        @json_data = []
      else
        @zipcode = Zipcode.find(params[:id])
        @town = Town.find(@zipcode.town)
        @province = Province.find(@town.province)
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id }
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update fileds from street_directory
    def update_province_textfield_from_street_directory

      if params[:id] == "0"
        @json_data = []
      else
        @street_directory = StreetDirectory.find(params[:id])
        @street_type = StreetType.find(@street_directory.street_type)
        @street_name = StreetDirectory.find(params[:id]).street_name
        @town = Town.find(@street_directory.town)
        @province = Province.find(@town.province)
        @region = Region.find(@province.region)
        @country = Country.find(@region.country)
        @json_data = { "town_id" => @town.id, "province_id" => @province.id, "region_id" => @region.id, "country_id" => @country.id, "street_type_id" => @street_type.id, "street_name" => @street_name}
      end

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update service point code at view (generate_code_sp_btn)
    def serpoint_generate_no
      office = params[:id]
      # Builds code, if possible
      code = office == '$' ? '$err' : serpoint_next_no(office)
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Look for meter
    #
    def sp_find_meter
      m = params[:meter]
      alert = ""
      code = ''
      meter_id = 0
      if m != '0'
        meter = Meter.find_by_meter_code(m) rescue nil
        if !meter.nil?
          s = Subscriber.find_by_meter_id(meter.id) rescue nil
          if s.nil?
            # Meter available
            alert = I18n.t("activerecord.errors.models.meter.available", var: m)
            meter_id = meter.id
          elsif !s.activated?
            # Meter installed and unavailable
            # Meter can be tested for been installed using meter.is_installed_now?
            alert = I18n.t("activerecord.errors.models.meter.available", var: m)
            code = '$shared'
            meter_id = meter.id
          elsif meter.is_shared?
            # Meter installed and unavailable
            # Meter can be tested for been installed using meter.is_installed_now?
            alert = I18n.t("activerecord.errors.models.meter.installed_share", var: m)
            code = '$shared'
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

    # GET /service_point
    def index
      manage_filter_state
      letter = params[:letter]
      if !session[:organization]
        init_oco
      end

      @search = ServicePoint.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        if !letter.blank? && letter != "%"
          any_of do
            with(:service_address).starting_with(letter)
          end
        end
        order_by :code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @service_points = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @service_points }
        format.js
      end
    end


    # GET /service_point
    def show
      @breadcrumb = 'read'
      @service_point = ServicePoint.find(params[:id])
      @readings = @service_point.readings.paginate(:page => params[:page], :per_page => per_page).by_id_desc
      @meter = @service_point.meter rescue nil
      @reading = Reading.new
      @billing_period = BillingPeriod.order('period DESC').all
      @reading_type = ReadingType.single_manual_reading
      @project_dropdown = projects_dropdown
      @subscriber = @service_point.subscribers.activated.size > 1 ? nil : @service_point.subscribers.activated.first
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @service_point }
      end
    end

    # GET /service_point
    def new
      @breadcrumb = 'create'
      @service_point = ServicePoint.new
      @companies = companies_dropdown
      @offices = offices_dropdown
      @reading_routes = reading_routes_dropdown
      @zipcodes = zipcodes_dropdown
      if session[:office] != '0'
        @office_center = Office.find(session[:office])
        @centers = Center.where(town_id: @office_center.town_id.to_i).order('name')
      else
        @centers = Center.all(order: 'name')
      end

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @service_point }
      end
    end

    # GET /service_point
    def edit
      @breadcrumb = 'update'
      @service_point = ServicePoint.find(params[:id])
      @companies = @service_point.organization.blank? ? companies_dropdown : companies_dropdown_edit(@service_point.organization)
      @offices = @service_point.organization.blank? ? offices_dropdown : offices_dropdown_edit(@service_point.organization_id)
      @reading_routes = reading_routes_dropdown
      @zipcodes = zipcodes_dropdown
      if session[:office] != '0'
        @office_center = Office.find(session[:office])
        @centers = Center.where(town_id: @office_center.town_id.to_i).order('name')
      else
        @centers = Center.all(order: 'name')
      end
    end

    # POST /service
    def create
      @breadcrumb = 'create'
      @service_point = ServicePoint.new(params[:service_point])
      @service_point.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point.save
          format.json { render json: @service_point.to_json(:methods => :to_full_label) }
          format.html { redirect_to @service_point, notice: t('activerecord.attributes.service_point.create') }
        else
          @companies = companies_dropdown
          @offices = offices_dropdown
          @reading_routes = reading_routes_dropdown
          @zipcodes = zipcodes_dropdown
          format.html { render action: "new" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /service_point
    def update
      @breadcrumb = 'update'
      @service_point = ServicePoint.find(params[:id])
      @service_point.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @service_point.update_attributes(params[:service_point])
          format.html { redirect_to @service_point,
                        notice: (crud_notice('updated', @service_point) + "#{undo_link(@service_point)}").html_safe }
          format.json { head :no_content }
        else
          @companies = @project.organization.blank? ? companies_dropdown : companies_dropdown_edit(@project.organization)
          @offices = @project.organization.blank? ? offices_dropdown : offices_dropdown_edit(@project.organization_id)
          @reading_routes = reading_routes_dropdown
          @zipcodes = zipcodes_dropdown
          format.html { render action: "edit" }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /service_point
    def destroy
      @service_point = ServicePoint.find(params[:id])

      respond_to do |format|
        if @service_point.destroy
          format.html { redirect_to service_points_url,
                      notice: (crud_notice('destroyed', @service_point) + "#{undo_link(@service_point)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to service_points_url, alert: "#{@service_point.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @service_point.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def projects_dropdown
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).ser_or_tca_order_type
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).ser_or_tca_order_type
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).ser_or_tca_order_type : Project.ser_or_tca_order_type
      end
    end

    def projects_dropdown_ids
      projects_dropdown.pluck(:id)
    end

    def zipcodes_dropdown
      Zipcode.order(:zipcode).includes(:town,:province)
    end

    def companies_dropdown
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = session[:organization] != '0' ? Company.where(organization_id: session[:organization].to_i).order(:name) : Company.order(:name)
      end
    end

    def offices_dropdown
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = session[:organization] != '0' ? Office.joins(:company).where(companies: { organization_id: session[:organization].to_i }).order(:name) : Office.order(:name)
      end
    end

    def companies_dropdown_edit(_organization)
      if session[:company] != '0'
        _companies = Company.where(id: session[:company].to_i)
      else
        _companies = _organization.companies.order(:name)
      end
    end

    def offices_dropdown_edit(_organization)
      if session[:office] != '0'
        _offices = Office.where(id: session[:office].to_i)
      elsif session[:company] != '0'
        _offices = offices_by_company(session[:company].to_i)
      else
        _offices = Office.joins(:company).where(companies: { organization_id: _organization }).order(:name)
      end
    end

    def offices_by_company(_company)
      Office.where(company_id: _company).order(:name)
    end

    def reading_routes_dropdown
      if session[:office] != '0'
        ReadingRoute.by_office(session[:office].to_i)
      else
        ReadingRoute.by_code
      end
    end

    def sort_column
      ServicePoint.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    # Keeps filter state
    def manage_filter_state
      # search
      if params[:search]
        session[:search] = params[:search]
      elsif session[:search]
        params[:search] = session[:search]
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
      # sort
      if params[:sort]
        session[:sort] = params[:sort]
      elsif session[:sort]
        params[:sort] = session[:sort]
      end
      # direction
      if params[:direction]
        session[:direction] = params[:direction]
      elsif session[:direction]
        params[:direction] = session[:direction]
      end
    end
  end
end
