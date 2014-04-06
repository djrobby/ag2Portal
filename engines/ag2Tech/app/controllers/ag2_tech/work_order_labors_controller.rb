require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderLaborsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /work_order_labors
    # GET /work_order_labors.json
    def index
      @work_order_labors = WorkOrderLabor.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_labors }
      end
    end
  
    # GET /work_order_labors/1
    # GET /work_order_labors/1.json
    def show
      @breadcrumb = 'read'
      @work_order_labor = WorkOrderLabor.find(params[:id])
      @worker_orders = @work_order_labor.work_orders.paginate(:page => params[:page], :per_page => per_page).order('order_no')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_labor }
      end
    end
  
    # GET /work_order_labors/new
    # GET /work_order_labors/new.json
    def new
      @breadcrumb = 'create'
      @work_order_labor = WorkOrderLabor.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_labor }
      end
    end
  
    # GET /work_order_labors/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order_labor = WorkOrderLabor.find(params[:id])
    end
  
    # POST /work_order_labors
    # POST /work_order_labors.json
    def create
      @breadcrumb = 'create'
      @work_order_labor = WorkOrderLabor.new(params[:work_order_labor])
      @work_order_labor.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @work_order_labor.save
          format.html { redirect_to @work_order_labor, notice: crud_notice('created', @work_order_labor) }
          format.json { render json: @work_order_labor, status: :created, location: @work_order_labor }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_labor.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /work_order_labors/1
    # PUT /work_order_labors/1.json
    def update
      @breadcrumb = 'update'
      @work_order_labor = WorkOrderLabor.find(params[:id])
      @work_order_labor.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @work_order_labor.update_attributes(params[:work_order_labor])
          format.html { redirect_to @work_order_labor,
                        notice: (crud_notice('updated', @work_order_labor) + "#{undo_link(@work_order_labor)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_labor.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /work_order_labors/1
    # DELETE /work_order_labors/1.json
    def destroy
      @work_order_labor = WorkOrderLabor.find(params[:id])

      respond_to do |format|
        if @work_order_labor.destroy
          format.html { redirect_to work_order_labors_url,
                      notice: (crud_notice('destroyed', @work_order_labor) + "#{undo_link(@work_order_labor)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to work_order_labors_url, alert: "#{@work_order_labor.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @work_order_labor.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      WorkOrderLabor.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
