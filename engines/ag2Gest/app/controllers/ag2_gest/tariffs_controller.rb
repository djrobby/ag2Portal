require_dependency "ag2_gest/application_controller"
require 'will_paginate/array'

module Ag2Gest
  class TariffsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [ :create_pct,
                                                :update_billable_concept_select_from_project,
                                                :update_tariff_type_select_from_billing_concept2,
                                                :bi_endowments_inhabitants_users_from ]

    def bi_endowments_inhabitants_users_from
      bi = params[:billable_item_id]

      @billable_item = BillableItem.find(bi)
      response_hash = { billable_item: @billable_item }
      response_hash[:endowment] = @billable_item.bill_by_endowments
      response_hash[:inhabitant] = @billable_item.bill_by_inhabitants
      response_hash[:user] = @billable_item.bill_by_users
      respond_to do |format|
        format.json { render json: response_hash }
      end
    end

    def update_billable_concept_select_from_project
      project_ids = params[:project_ids]

      @billable_concept_ids = BillableConcept.belongs_to_project(project_ids.to_i)

      @billable_concept_dropdown = billable_concept_array(@billable_concept_ids)
      # Setup JSON
      @json_data = { "billable_concept_ids" => @billable_concept_dropdown }
      render json: @json_data
    end


    def update_tariff_type_select_from_billing_concept2
      billable_concept_ids = params[:billable_concept_ids]
      billable_concept_ids = billable_concept_ids.split(",")
      @tariff_type_ids = []
      @bc_ids = []
      billable_concept_ids.each do |bc|
        bil_concept = BillableConcept.find(bc).grouped_tariff_types
        if !bil_concept.blank? && !@bc_ids.include?(bil_concept[0].id.to_s)
          @tariff_type_ids += bil_concept
          @bc_ids << bil_concept[0].id.to_s
        end
      end
      @tariff_type_dropdown = tariff_type_array(@tariff_type_ids)
      # Setup JSON
      @json_data = { "tariff_type_ids" => @tariff_type_dropdown }
      render json: @json_data
    end

    def update_new_item_select_from_billing_concept2
      project_ids = params[:project_ids]
      billable_concept_ids = params[:billable_concept_ids]
      billable_concept_ids = billable_concept_ids.split(",")
      @new_item_ids = []
      billable_concept_ids.each do |bc|
        @new_item_ids += BillableItem.availables.where('billable_items.billable_concept_id = ? AND billable_items.project_id = ?',bc,project_ids)
      end
      @new_item_dropdown = new_item_array(@new_item_ids)
      # Setup JSON
      @json_data = { "new_item_ids" => @new_item_dropdown }
      render json: @json_data
    end


    def create_pct
      @project = Project.find(params[:project_id])
      if params[:billable_item].blank?
        @billable_item = ""
      else
        @billable_item = BillableItem.find(params[:billable_item])
      end
      _tariff_type_ids = params[:TariffType_]
      _billable_concept_ids = params[:BillableConcept_]
      @tariffs = []
      _billable_concept_ids.each do |bc|
        _billable_concept = BillableConcept.find(bc)
        _tariff_type_ids.each do |tt|
          _tariff_type = TariffType.find(tt)
          @tariffs += @project.tariffs.where('ending_at IS NULL AND tariff_type_id = ? AND billable_concept_id = ?',_tariff_type.id,_billable_concept.id).order(:billable_concept_id)
        end
      end
      # @tariffs = @project.billable_items.map(&:tariffs).flatten.select{|t| t.tariff_type_id == params[:tariff_types].to_i and t.ending_at.nil?}
      redirect_to tariffs_path, alert: I18n.t("ag2_gest.tariffs.generate_error") and return if @tariffs.blank?
      redirect_to tariffs_path, alert: I18n.t("ag2_gest.tariffs.generate_error_date") and return if @tariffs.first.starting_at > params[:init_date].to_date - 1.day
      @subscribers = Subscriber.joins(:subscriber_tariffs).where('(subscribers.ending_at IS NULL OR subscribers.ending_at >= ?) AND subscribers.active = true AND (subscriber_tariffs.tariff_id IN (?))', Date.today,@tariffs).group('subscribers.id')
      # @subscribers = @tariffs.map(&:subscribers).compact.flatten.uniq
      @new_tariffs = []
      @tariffs.each do |tariff|
        @new_tariffs << Tariff.create(
          billable_item_id: @billable_item.id,
          tariff_type_id: tariff.tariff_type_id,
          caliber_id: tariff.caliber_id,
          billing_frequency_id: tariff.billing_frequency_id,
          fixed_fee: tariff.fixed_fee + (tariff.fixed_fee * (params["pct_value"].to_f / 100)),
          variable_fee: tariff.variable_fee + (tariff.variable_fee * (params["pct_value"].to_f / 100)),
          percentage_fee: tariff.percentage_fee,
          percentage_applicable_formula: tariff.percentage_applicable_formula,
          percentage_fixed_fee: tariff.percentage_fixed_fee,
          block1_limit: tariff.block1_limit,
          block2_limit: tariff.block2_limit,
          block3_limit: tariff.block3_limit,
          block4_limit: tariff.block4_limit,
          block5_limit: tariff.block5_limit,
          block6_limit: tariff.block6_limit,
          block7_limit: tariff.block7_limit,
          block8_limit: tariff.block8_limit,
          block1_fee: tariff.block1_fee + (tariff.block1_fee * (params["pct_value"].to_f / 100)),
          block2_fee: tariff.block2_fee + (tariff.block2_fee * (params["pct_value"].to_f / 100)),
          block3_fee: tariff.block3_fee + (tariff.block3_fee * (params["pct_value"].to_f / 100)),
          block4_fee: tariff.block4_fee + (tariff.block4_fee * (params["pct_value"].to_f / 100)),
          block5_fee: tariff.block5_fee + (tariff.block5_fee * (params["pct_value"].to_f / 100)),
          block6_fee: tariff.block6_fee + (tariff.block6_fee * (params["pct_value"].to_f / 100)),
          block7_fee: tariff.block7_fee + (tariff.block7_fee * (params["pct_value"].to_f / 100)),
          block8_fee: tariff.block8_fee + (tariff.block8_fee * (params["pct_value"].to_f / 100)),
          discount_pct_f: tariff.discount_pct_f,
          discount_pct_v: tariff.discount_pct_v,
          discount_pct_p: tariff.discount_pct_p,
          discount_pct_b: tariff.discount_pct_b,
          tax_type_f_id: tariff.tax_type_f_id,
          tax_type_v_id: tariff.tax_type_v_id,
          tax_type_p_id: tariff.tax_type_p_id,
          tax_type_b_id: tariff.tax_type_b_id,
          connection_fee_a: tariff.connection_fee_a,
          connection_fee_b: tariff.connection_fee_b,
          endowments_from: tariff.endowments_from,
          endowments_increment: tariff.endowments_increment,
          endowments_increment_apply_to: tariff.endowments_increment_apply_to,
          inhabitants_from: tariff.inhabitants_from,
          inhabitants_increment: tariff.inhabitants_increment,
          inhabitants_increment_apply_to: tariff.inhabitants_increment_apply_to,
          users_from: tariff.users_from,
          users_increment: tariff.users_increment,
          users_increment_apply_to: tariff.users_increment_apply_to,
          starting_at: params[:init_date]
        )
      end
        @subscribers.each do |s|
          tariffs_assing = @new_tariffs.select{|t| (t.caliber_id.nil? || t.caliber_id == s.meter.caliber_id) and t.billable_concept.billable_document == "1"}
          s.tariffs << tariffs_assing
        end
      _end_date = @new_tariffs.first.starting_at - 1.day
      @tariffs.each{|t| t.update_attributes(ending_at: _end_date)}
      redirect_to tariffs_path, notice: I18n.t("ag2_gest.tariffs.generate_ok")
    end

    # GET /tariffs
    # GET /tariffs.json
    def index
      manage_filter_state_index
      filter_tariff_index = params[:ifilter_index_tariff] || "all"
      @active_ifilter_tariff_index = filter_tariff_index

      manage_filter_state

      project = params[:Project]
      concept = params[:Concept]
      item = params[:Item]
      type = params[:Type]
      caliber = params[:Caliber]
      frequency = params[:Frequency]
      from = params[:From]
      to = params[:To]
      # OCO
      init_oco if !session[:organization]
      # Initialize select_tags
      @projects = current_projects if @projects.nil?
      @concepts = billable_concept_dropdown
      @items = billable_item_dropdown
      @types = tariff_type_dropdown
      @calibers = caliber_dropdown
      @frequencies = billing_frequency_dropdown

      # @tariffs = ActiveTariff.belongs_to_project(current_projects_ids) if @tariffs.nil?
      # search = Tariff.group(:billable_item_id, :tariff_type_id, :billing_frequency_id, :starting_at, :ending_at).search do
      #   # group :grouped_tariffs
      #   # group :billable_item_id_str, :tariff_type_id_str, :billing_frequency_id_str, :starting_at_str, :ending_at_str
      #   with :project_id, current_projects_ids unless current_projects_ids.blank?
      #   fulltext params[:search]
      #   if !project.blank?
      #     with :project_id, project
      #   end
      #   if !type.blank?
      #     with :tariff_type_id, type
      #   end
      #   if !concept.blank?
      #     with :billable_concept_code, concept
      #   end
      #   if !item.blank?
      #     with :billable_item_id, item
      #   end
      #   if !caliber.blank?
      #     with :caliber_id, caliber
      #   end
      #   if !frequency.blank?
      #     with :billing_frequency_id, frequency
      #   end
      #   if !from.blank?
      #     any_of do
      #       with(:starting_at).greater_than(from)
      #       with :starting_at, from
      #     end
      #   end
      #   if !to.blank?
      #     any_of do
      #       with(:ending_at).less_than(to)
      #       with :ending_at, to
      #     end
      #   end
      #   order_by :tariff_type_id
      #   paginate :page => params[:page] || 1, :per_page => per_page || 10
      # end
      # @grouped_tariffs = search.results
      # # @grouped_tariffs = search.group(:grouped_tariffs).groups.each do |g|

      # @grouped_tariffs = search.group(:grouped_tariffs).groups.each do |g|
      #   g.results
      # end

      # @grouped_tariffs = Tariff.all_group_tariffs_without_caliber(current_projects_ids || project, type, concept, item, caliber, frequency, from, to).paginate :page => params[:page] || 1, :per_page => Tariff.count

      if filter_tariff_index == "all"
        @grouped_tariffs = Tariff.search_box(current_projects_ids.join(', ') || project, type, concept, item, caliber, frequency, from, to).to_a.paginate(:page => params[:page] || 1, :per_page => 15)
      elsif filter_tariff_index == "activated"
        @grouped_tariffs = Tariff.current.search_box(current_projects_ids.join(', ') || project, type, concept, item, caliber, frequency, from, to).to_a.paginate(:page => params[:page] || 1, :per_page => 15)
      elsif filter_tariff_index == "deactivated"
        @grouped_tariffs = Tariff.not_current.search_box(current_projects_ids.join(', ') || project, type, concept, item, caliber, frequency, from, to).to_a.paginate(:page => params[:page] || 1, :per_page => 15)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @grouped_tariffs }
        format.js
      end
    end

    def show
      @breadcrumb = 'read'
      @tariff = Tariff.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tariff }
      end
    end

    def new
      @breadcrumb = 'create'
      @tariff = Tariff.new
      @tariff_types = tariff_type_dropdown
      @tax_type = tax_type_dropdown
      @billable_items = billable_item_dropdown.joins(:billable_concept)#.where("billable_concepts.billable_document = 1")
      @calibers = caliber_dropdown
      @billing_frequencies = billing_frequency_dropdown
      @billable_concept_percentage = billable_item_dropdown.joins(:billable_concept).where("billable_concepts.billable_document = 1").group("billable_concepts.id").map(&:billable_concept)

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tariff }
      end
    end

    def edit
      @breadcrumb = 'update'
      @tariff = Tariff.find(params[:id])
      @tariff_types = tariff_type_dropdown
      @tax_type = tax_type_dropdown
      @billable_items = billable_item_dropdown.joins(:billable_concept)#.where("billable_concepts.billable_document = 1")
      @calibers = caliber_dropdown
      @billing_frequencies = billing_frequency_dropdown
      @billable_concept_percentage = billable_item_dropdown.joins(:billable_concept).where("billable_concepts.billable_document = 1").group("billable_concepts.id").map(&:billable_concept)
    end

    def create
      @breadcrumb = 'create'
      @tariff_types = tariff_type_dropdown
      @tax_type = tax_type_dropdown
      @billable_items = billable_item_dropdown.joins(:billable_concept).where("billable_concepts.billable_document = 1")
      @calibers = caliber_dropdown
      @billing_frequencies = billing_frequency_dropdown
      @billable_concept_percentage = billable_item_dropdown.joins(:billable_concept).where("billable_concepts.billable_document = 1").group("billable_concepts.id").map(&:billable_concept)
      @tariff = Tariff.new(params[:tariff])
      @tariff.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @tariff.save
          format.html { redirect_to @tariff, notice: t('activerecord.attributes.tariff.create') }
          format.json { render json: @tariff, status: :created, location: @tariff }
        else
          format.html { render action: "new" }
          format.json { render json: @tariff.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /tariffs/1
    # PUT /tariffs/1.json
    def update
      @breadcrumb = 'update'
      @tariff = Tariff.find(params[:id])
      @tariff.updated_by = current_user.id if !current_user.nil?
      @tariff_types = tariff_type_dropdown
      @tax_type = tax_type_dropdown
      @billable_items = billable_item_dropdown.joins(:billable_concept)#.where("billable_concepts.billable_document = 1")
      @calibers = caliber_dropdown
      @billing_frequencies = billing_frequency_dropdown
      @billable_concept_percentage = billable_item_dropdown.joins(:billable_concept).where("billable_concepts.billable_document = 1").group("billable_concepts.id").map(&:billable_concept)

      respond_to do |format|
        if @tariff.update_attributes(params[:tariff])
          format.html { redirect_to @tariff,
                        notice: (crud_notice('updated', @tariff) + "#{undo_link(@tariff)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit", alert: @tariff.errors.messages }
          format.json { render json: @tariff.errors, status: :unprocessable_entity }
        end
      end
    end


    # DELETE /tariffs/1
    # DELETE /tariffs/1.json
    # def destroy
    #   @tariff = Tariff.find(params[:id])
    #   @tariff_scheme = @tariff.tariff_scheme
    #   @tariff.block1_fee = 0.0
    #   @tariff.block2_fee = 0.0
    #   @tariff.block3_fee = 0.0
    #   @tariff.block4_fee = 0.0
    #   @tariff.block5_fee = 0.0
    #   @tariff.block6_fee = 0.0
    #   @tariff.block7_fee = 0.0
    #   @tariff.block8_fee = 0.0
    #   @tariff.fixed_fee = 0.0
    #   @tariff.variable_fee = 0.0
    #   @tariff.percentage_fee = 0.0
    #
    #   respond_to do |format|
    #     if @tariff.save
    #       format.html { redirect_to tariff_scheme_url(@tariff_scheme), notice: "Tarifa eliminada" }
    #       format.json { render json: @tariff_scheme, status: :created, location: @tariff_scheme }
    #     else
    #       format.html { redirect_to tariff_scheme_url(@tariff_scheme), alert: "Error al eliminar tarifa" }
    #       format.json { render json: @tariff_scheme.errors, status: :unprocessable_entity }
    #     end
    #   end
    # end
    def destroy
      @tariff = Tariff.find(params[:id])

      respond_to do |format|
        if @tariff.destroy
          format.html { redirect_to tariffs_url,
                      notice: (crud_notice('destroyed', @tariff) + "#{undo_link(@tariff)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to tariffs_url, alert: "#{@tariff.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @tariff.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def billable_concept_array(_billable_concept)
      _array = []
      _billable_concept.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def tariff_type_array(_tariff_type)
      _array = []
      _tariff_type.each do |i|
        _array = _array << [i.id, i.to_label]
      end
      _array
    end

    def new_item_array(_new_item)
      _array = []
      _new_item.each do |i|
        _array = _array << [i.id, i.to_label_date]
      end
      _array
    end

    def tariff_type_dropdown
      TariffType.all
    end

    def tax_type_dropdown
      TaxType.current
    end

    def billable_concept_dropdown
        BillableConcept.all
    end

    def billable_item_dropdown
      if session[:organization]
        BillableItem.availables.where(project_id: current_projects_ids)
      else
        BillableItem.availables
      end
    end

    def caliber_dropdown
      Caliber.all
    end

    def billing_frequency_dropdown
      BillingFrequency.all
    end

    def manage_filter_state_index
      if params[:ifilter_index_tariff]
        session[:ifilter_index_tariff] = params[:ifilter_index_tariff]
      elsif session[:ifilter_index_tariff]
        params[:ifilter_index_tariff] = session[:ifilter_index_tariff]
      end
    end

    # Keeps filter state
    def manage_filter_state

      # Project
      if params[:Project]
        session[:Project] = params[:Project]
      elsif session[:Project]
        params[:Project] = session[:Project]
      end

      # Concept
      if params[:Concept]
        session[:Concept] = params[:Concept]
      elsif session[:Concept]
        params[:Concept] = session[:Concept]
      end

      # Item
      if params[:Item]
        session[:Item] = params[:Item]
      elsif session[:Item]
        params[:Item] = session[:Item]
      end

      # Company
      if params[:Type]
        session[:Type] = params[:Type]
      elsif session[:Type]
        params[:Type] = session[:Type]
      end

      # From
      if params[:From]
        session[:From] = params[:From]
      elsif session[:From]
        params[:From] = session[:From]
      end

      # To
      if params[:To]
        session[:To] = params[:To]
      elsif session[:To]
        params[:To] = session[:To]
      end
    end

  end
end
