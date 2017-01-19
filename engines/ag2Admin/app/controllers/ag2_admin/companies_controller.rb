require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CompaniesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :co_update_attachment,
                                               :co_update_total_and_price,
                                               :co_update_from_organization,
                                               :co_update_office_select_from_bank,
                                               :co_check_iban]
    # Helper methods for
    # => sorting
    # => allow edit (hide buttons)
    helper_method :sort_column, :cannot_edit
    # Public attachment for drag&drop
    $attachment = nil

    # Update attached file from drag&drop
    def co_update_attachment
      if !$attachment.nil?
        $attachment.destroy
        $attachment = Attachment.new
      end
      $attachment.avatar = params[:file]
      $attachment.id = 1
      #$attachment.save!
      if $attachment.save
        render json: { "image" => $attachment.avatar }
      else
        render json: { "image" => "" }
      end
    end

    # Update hidden province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update hidden province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update total & price text fields at view (formatting)
    def co_update_total_and_price
      total = params[:total].to_f / 100
      price = params[:price].to_f / 10000
      overtime = params[:overtime].to_f / 100
      # Format number
      total = number_with_precision(total.round(2), precision: 2)
      price = number_with_precision(price.round(4), precision: 4)
      overtime = number_with_precision(overtime.round(2), precision: 2)
      # Setup JSON
      @json_data = { "total" => total.to_s, "price" => price.to_s, "overtime" => overtime.to_s }
      render json: @json_data
    end

    # Update users from organization select
    def co_update_from_organization
      organization = params[:company]
      if organization != '0'
        @organization = Organization.find(organization)
        @users = @organization.blank? ? users_dropdown : users_dropdown
        #@users = @organization.blank? ? users_dropdown : @organization.users.order(:email)
      else
        @users = users_dropdown
      end
      @json_data = { "users" => @users }
      render json: @json_data
    end

    # Update office select at view from bank select
    def co_update_office_select_from_bank
      bank = params[:bank]
      if bank != '0'
        @bank = Bank.find(bank)
        @offices = @bank.blank? ? bank_offices_dropdown : @bank.bank_offices.order(:bank_id, :code)
      else
        @offices = bank_offices_dropdown
      end
      # Offers array
      @offices_dropdown = bank_offices_array(@offices)
      # Setup JSON
      @json_data = { "office" => @offices_dropdown }
      render json: @json_data
    end

    # Check IBAN
    def co_check_iban
      iban = check_iban(params[:country], params[:dc], params[:bank], params[:office], params[:account])
      # Setup JSON
      @json_data = { "iban" => iban }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /companies
    # GET /companies.json
    def index
      manage_filter_state
      if session[:organization] != '0'
        @companies = Company.where("organization_id = ?", "#{session[:organization]}").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @companies = Company.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @companies }
        format.js
      end
    end

    # GET /companies/1
    # GET /companies/1.json
    def show
      @breadcrumb = 'read'
      @company = Company.find(params[:id])
      @offices = @company.offices.paginate(:page => params[:page], :per_page => per_page).order(:office_code)
      @notifications = @company.company_notifications.paginate(:page => params[:page], :per_page => per_page).order('id')
      @accounts = @company.company_bank_accounts.paginate(:page => params[:page], :per_page => per_page).order(:id)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @company }
      end
    end

    # GET /companies/new
    # GET /companies/new.json
    def new
      @breadcrumb = 'create'
      @company = Company.new
      @notifications = notifications_dropdown
      @users = users_dropdown
      @classes = bank_account_classes_dropdown
      @countries = countries_dropdown
      @banks = banks_dropdown
      @offices = bank_offices_dropdown
      $attachment = Attachment.new
      destroy_attachment

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @company }
      end
    end

    # GET /companies/1/edit
    def edit
      @breadcrumb = 'update'
      @company = Company.find(params[:id])
      @notifications = notifications_dropdown
      @users = users_dropdown
      @classes = bank_account_classes_dropdown
      @countries = countries_dropdown
      @banks = banks_dropdown
      @offices = bank_offices_dropdown
      $attachment = Attachment.new
      destroy_attachment
    end

    # POST /companies
    # POST /companies.json
    def create
      @breadcrumb = 'create'
      @company = Company.new(params[:company])
      @company.created_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if @company.logo.blank? && !$attachment.avatar.blank?
        @company.logo = $attachment.avatar
      end

      respond_to do |format|
        if @company.save
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @company, notice: crud_notice('created', @company) }
          format.json { render json: @company, status: :created, location: @company }
        else
          @notifications = notifications_dropdown
          @users = users_dropdown
          @classes = bank_account_classes_dropdown
          @countries = countries_dropdown
          @banks = banks_dropdown
          @offices = bank_offices_dropdown
          $attachment.destroy
          $attachment = Attachment.new
          format.html { render action: "new" }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /companies/1
    # PUT /companies/1.json
    def update
      @breadcrumb = 'update'
      @company = Company.find(params[:id])
      @company.updated_by = current_user.id if !current_user.nil?
      # Should use attachment from drag&drop?
      if !$attachment.avatar.blank? && $attachment.updated_at > @company.updated_at
        @company.logo = $attachment.avatar
      end

      respond_to do |format|
        if @company.update_attributes(params[:company])
          $attachment.destroy
          $attachment = nil
          format.html { redirect_to @company,
                        notice: (crud_notice('updated', @company) + "#{undo_link(@company)}").html_safe }
          format.json { head :no_content }
        else
          @notifications = notifications_dropdown
          @users = users_dropdown
          @classes = bank_account_classes_dropdown
          @countries = countries_dropdown
          @banks = banks_dropdown
          @offices = bank_offices_dropdown
          $attachment.destroy
          $attachment = Attachment.new
          format.html { render action: "edit" }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /companies/1
    # DELETE /companies/1.json
    def destroy
      @company = Company.find(params[:id])

      respond_to do |format|
        if @company.destroy
          format.html { redirect_to companies_url,
                      notice: (crud_notice('destroyed', @company) + "#{undo_link(@company)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to companies_url, alert: "#{@company.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def notifications_dropdown
      Notification.order(:id)
    end

    def users_dropdown
      User.order(:email)
    end

    def bank_account_classes_dropdown
      BankAccountClass.where('id >= ?', 6).order(:id)
    end

    def countries_dropdown
      Country.order(:code)
    end

    def banks_dropdown
      Bank.order(:code)
    end

    def bank_offices_dropdown
      BankOffice.order(:bank_id, :code)
    end

    def bank_offices_array(_offices)
      _array = []
      _offices.each do |i|
        _array = _array << [i.id, i.code, i.name, "(" + i.bank.code + ")"]
      end
      _array
    end

    def sort_column
      Company.column_names.include?(params[:sort]) ? params[:sort] : "fiscal_id"
    end

    def cannot_edit(_company)
      session[:company] != '0' && _company != session[:company].to_i
    end

    # Keeps filter state
    def manage_filter_state
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
