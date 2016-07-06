require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderAreasController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /work_order_areas
    # GET /work_order_areas.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @work_order_areas = WorkOrderArea.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @work_order_areas = WorkOrderArea.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_areas }
        format.js
      end
    end

    # GET /work_order_areas/1
    # GET /work_order_areas/1.json
    def show
      @breadcrumb = 'read'
      @work_order_area = WorkOrderArea.find(params[:id])
      @worker_orders = @work_order_area.work_orders.paginate(:page => params[:page], :per_page => per_page).order(:order_no)
      @types = @work_order_area.work_order_types.paginate(:page => params[:page], :per_page => per_page).order(:id)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_area }
      end
    end

    # GET /work_order_areas/new
    # GET /work_order_areas/new.json
    def new
      @breadcrumb = 'create'
      @work_order_area = WorkOrderArea.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_area }
      end
    end

    # GET /work_order_areas/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order_area = WorkOrderArea.find(params[:id])
    end

    # POST /work_order_areas
    # POST /work_order_areas.json
    def create
      @breadcrumb = 'create'
      @work_order_area = WorkOrderArea.new(params[:work_order_area])
      @work_order_area.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @work_order_area.save
          format.html { redirect_to @work_order_area, notice: crud_notice('created', @work_order_area) }
          format.json { render json: @work_order_area, status: :created, location: @work_order_area }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_area.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /work_order_areas/1
    # PUT /work_order_areas/1.json
    def update
      @breadcrumb = 'update'
      @work_order_area = WorkOrderArea.find(params[:id])
      @work_order_area.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @work_order_area.update_attributes(params[:work_order_area])
          format.html { redirect_to @work_order_area,
                        notice: (crud_notice('updated', @work_order_area) + "#{undo_link(@work_order_area)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_area.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /work_order_areas/1
    # DELETE /work_order_areas/1.json
    def destroy
      @work_order_area = WorkOrderArea.find(params[:id])

      respond_to do |format|
        if @work_order_area.destroy
          format.html { redirect_to work_order_areas_url,
                      notice: (crud_notice('destroyed', @work_order_area) + "#{undo_link(@work_order_area)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to work_order_areas_url, alert: "#{@work_order_area.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @work_order_area.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      WorkOrderArea.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
