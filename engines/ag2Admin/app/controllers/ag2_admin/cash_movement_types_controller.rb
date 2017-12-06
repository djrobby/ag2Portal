require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CashMovementTypesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /cash_movement_types
    # GET /cash_movement_types.json
    def index
      manage_filter_state
      filter = params[:ifilter]
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @cash_movement_types = type_filter_organization(filter, session[:organization].to_i)
      else
        @cash_movement_types = type_filter(filter)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @cash_movement_types }
        format.js
      end
    end

    # GET /cash_movement_types/1
    # GET /cash_movement_types/1.json
    def show
      @breadcrumb = 'read'
      @cash_movement_type = CashMovementType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @cash_movement_type }
      end
    end

    # GET /cash_movement_types/new
    # GET /cash_movement_types/new.json
    def new
      @breadcrumb = 'create'
      @cash_movement_type = CashMovementType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @cash_movement_type }
      end
    end

    # GET /cash_movement_types/1/edit
    def edit
      @breadcrumb = 'update'
      @cash_movement_type = CashMovementType.find(params[:id])
    end

    # POST /cash_movement_types
    # POST /cash_movement_types.json
    def create
      @breadcrumb = 'create'
      @cash_movement_type = CashMovementType.new(params[:cash_movement_type])
      @cash_movement_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @cash_movement_type.save
          format.html { redirect_to @cash_movement_type, notice: crud_notice('created', @cash_movement_type) }
          format.json { render json: @cash_movement_type, status: :created, location: @cash_movement_type }
        else
          format.html { render action: "new" }
          format.json { render json: @cash_movement_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /cash_movement_types/1
    # PUT /cash_movement_types/1.json
    def update
      @breadcrumb = 'update'
      @cash_movement_type = CashMovementType.find(params[:id])
      @cash_movement_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @cash_movement_type.update_attributes(params[:cash_movement_type])
          format.html { redirect_to @cash_movement_type,
                        notice: (crud_notice('updated', @cash_movement_type) + "#{undo_link(@cash_movement_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @cash_movement_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /cash_movement_types/1
    # DELETE /cash_movement_types/1.json
    def destroy
      @cash_movement_type = CashMovementType.find(params[:id])

      respond_to do |format|
        if @cash_movement_type.destroy
          format.html { redirect_to cash_movement_types_url,
                      notice: (crud_notice('destroyed', @cash_movement_type) + "#{undo_link(@cash_movement_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to cash_movement_types_url, alert: "#{@cash_movement_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @cash_movement_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def type_filter(_filter)
      if _filter == "all"
        CashMovementType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "inflow"
        CashMovementType.inflows_u.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "outflow"
        CashMovementType.outflows_u.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        CashMovementType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
    end

    def type_filter_organization(_filter, _organization)
      if _filter == "all"
        CashMovementType.belongs_to_organization_u(_organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "inflow"
        CashMovementType.inflows_by_organization_u(_organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif _filter == "outflow"
        CashMovementType.outflows_by_organization_u(_organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        CashMovementType.belongs_to_organization_u(_organization).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
    end

    def sort_column
      CashMovementType.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
      # ifilter
      if params[:ifilter]
        session[:ifilter] = params[:ifilter]
      elsif session[:ifilter]
        params[:ifilter] = session[:ifilter]
      end
    end
  end
end
