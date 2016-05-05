require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ZonesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:zo_update_total_and_price]

    # Helper methods for
    # => sorting
    # => allow edit (hide buttons)
    helper_method :sort_column

    # Update total & price text fields at view (formatting)
    def zo_update_total_and_price
      total = params[:total].to_f / 100
      price = params[:price].to_f / 10000
      # Format number
      total = number_with_precision(total.round(2), precision: 2)
      price = number_with_precision(price.round(4), precision: 4)
      # Setup JSON
      @json_data = { "total" => total.to_s, "price" => price.to_s }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /zones
    # GET /zones.json
    def index
      manage_filter_state
      if session[:organization] != '0'
        @zones = Zone.where("organization_id = ?", "#{session[:organization]}").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @zones = Zone.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @zones }
        format.js
      end
    end

    # GET /zones/1
    # GET /zones/1.json
    def show
      @breadcrumb = 'read'
      @zone = Zone.find(params[:id])
      @offices = @zone.offices.paginate(:page => params[:page], :per_page => per_page).order(:office_code)
      @notifications = @zone.zone_notifications.paginate(:page => params[:page], :per_page => per_page).order('id')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @zone }
      end
    end

    # GET /zones/new
    # GET /zones/new.json
    def new
      @breadcrumb = 'create'
      @zone = Zone.new
      @notifications = notifications_dropdown
      @users = users_dropdown
      @workers = workers_dropdown

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @zone }
      end
    end

    # GET /zones/1/edit
    def edit
      @breadcrumb = 'update'
      @zone = Zone.find(params[:id])
      @notifications = notifications_dropdown
      @users = users_dropdown
      @workers = workers_dropdown
    end

    # POST /zones
    # POST /zones.json
    def create
      @breadcrumb = 'create'
      @zone = Zone.new(params[:zone])
      @zone.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @zone.save
          format.html { redirect_to @zone, notice: crud_notice('created', @zone) }
          format.json { render json: @zone, status: :created, location: @zone }
        else
          @notifications = notifications_dropdown
          @users = users_dropdown
          @workers = workers_dropdown
          format.html { render action: "new" }
          format.json { render json: @zone.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /zones/1
    # PUT /zones/1.json
    def update
      @breadcrumb = 'update'
      @zone = Zone.find(params[:id])
      @zone.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @zone.update_attributes(params[:zone])
          format.html { redirect_to @zone,
                        notice: (crud_notice('updated', @zone) + "#{undo_link(@zone)}").html_safe }
          format.json { head :no_content }
        else
          @notifications = notifications_dropdown
          @users = users_dropdown
          @workers = workers_dropdown
          format.html { render action: "edit" }
          format.json { render json: @zone.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /zones/1
    # DELETE /zones/1.json
    def destroy
      @zone = Zone.find(params[:id])

      respond_to do |format|
        if @zone.destroy
          format.html { redirect_to zones_url,
                      notice: (crud_notice('destroyed', @zone) + "#{undo_link(@zone)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to zones_url, alert: "#{@zone.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @zone.errors, status: :unprocessable_entity }
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

    def workers_dropdown
      if session[:company] != '0'
        _workers = workers_by_company(session[:company].to_i)
      else
        _workers = session[:organization] != '0' ? Worker.where(organization_id: session[:organization].to_i).order(:last_name, :first_name) : Worker.order(:last_name, :first_name)
      end
    end

    def workers_by_company(_company)
      _workers = Worker.joins(:worker_items).group('worker_items.worker_id').where(worker_items: { company_id: _company }).order(:last_name, :first_name)
    end

    def sort_column
      Zone.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
