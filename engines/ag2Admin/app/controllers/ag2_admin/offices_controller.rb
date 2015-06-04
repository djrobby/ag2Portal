require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class OfficesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_code_textfield_from_zipcode]
    # Helper methods for
    # => sorting
    # => allow edit (hide buttons)
    helper_method :sort_column, :cannot_edit
    #    def internal
    #      @companies = Company.all
    #    end
    # Update office code at view from zip code select (button from edit or new)
    def update_code_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @json_data = { "zipcode" => @zipcode.zipcode }

      respond_to do |format|
        format.html # update_code_textfield_from_zipcode.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id, "zipcode" => @zipcode.zipcode }

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /offices
    # GET /offices.json
    def index
      #      internal
      manage_filter_state
      if !session[:organization]
        init_oco
      end
      if session[:organization] != '0'
        # OCO organization active
        @offices = Office.joins(:company).where(companies: { organization_id: session[:organization] }).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        # OCO inactive
        @offices = Office.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @offices }
        format.js
      end
    end

    # GET /offices/1
    # GET /offices/1.json
    def show
      @breadcrumb = 'read'
      @office = Office.find(params[:id])
      @notifications = @office.office_notifications.paginate(:page => params[:page], :per_page => per_page).order('id')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @office }
      end
    end

    # GET /offices/new
    # GET /offices/new.json
    def new
      #      internal
      @breadcrumb = 'create'
      @office = Office.new
      @notifications = notifications_dropdown
      @users = users_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @office }
      end
    end

    # GET /offices/1/edit
    def edit
      #      internal
      @breadcrumb = 'update'
      @office = Office.find(params[:id])
      @notifications = notifications_dropdown
      @users = users_dropdown
    end

    # POST /offices
    # POST /offices.json
    def create
      #      internal
      @breadcrumb = 'create'
      @office = Office.new(params[:office])
      @office.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @office.save
          format.html { redirect_to @office, notice: crud_notice('created', @office) }
          format.json { render json: @office, status: :created, location: @office }
        else
          @notifications = notifications_dropdown
          @users = users_dropdown
          format.html { render action: "new" }
          format.json { render json: @office.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /offices/1
    # PUT /offices/1.json
    def update
      #      internal
      @breadcrumb = 'update'
      @office = Office.find(params[:id])
      @office.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @office.update_attributes(params[:office])
          format.html { redirect_to @office,
                        notice: (crud_notice('updated', @office) + "#{undo_link(@office)}").html_safe }
          format.json { head :no_content }
        else
          @notifications = notifications_dropdown
          @users = users_dropdown
          format.html { render action: "edit" }
          format.json { render json: @office.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /offices/1
    # DELETE /offices/1.json
    def destroy
      @office = Office.find(params[:id])

      respond_to do |format|
        if @office.destroy
          format.html { redirect_to offices_url,
                      notice: (crud_notice('destroyed', @office) + "#{undo_link(@office)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to offices_url, alert: "#{@office.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @office.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def notifications_dropdown
      Notification.order(:name)
    end

    def users_dropdown
      User.order(:email)
    end

    def sort_column
      Office.column_names.include?(params[:sort]) ? params[:sort] : "office_code"
    end
    
    def cannot_edit(_office, _company)
      (session[:office] != '0' && _office != session[:office].to_i) ||
      (session[:company] != '0' && _company != session[:company].to_i)
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
