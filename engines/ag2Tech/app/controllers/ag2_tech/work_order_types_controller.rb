require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class WorkOrderTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /work_order_types
    # GET /work_order_types.json
    def index
      @work_order_types = WorkOrderType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @work_order_types }
      end
    end
  
    # GET /work_order_types/1
    # GET /work_order_types/1.json
    def show
      @breadcrumb = 'read'
      @work_order_type = WorkOrderType.find(params[:id])
      @worker_orders = @work_order_type.work_orders.paginate(:page => params[:page], :per_page => per_page).order('order_no')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @work_order_type }
      end
    end
  
    # GET /work_order_types/new
    # GET /work_order_types/new.json
    def new
      @breadcrumb = 'create'
      @work_order_type = WorkOrderType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @work_order_type }
      end
    end
  
    # GET /work_order_types/1/edit
    def edit
      @breadcrumb = 'update'
      @work_order_type = WorkOrderType.find(params[:id])
    end
  
    # POST /work_order_types
    # POST /work_order_types.json
    def create
      @breadcrumb = 'create'
      @work_order_type = WorkOrderType.new(params[:work_order_type])
      @work_order_type.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @work_order_type.save
          format.html { redirect_to @work_order_type, notice: crud_notice('created', @work_order_type) }
          format.json { render json: @work_order_type, status: :created, location: @work_order_type }
        else
          format.html { render action: "new" }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /work_order_types/1
    # PUT /work_order_types/1.json
    def update
      @breadcrumb = 'update'
      @work_order_type = WorkOrderType.find(params[:id])
      @work_order_type.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @work_order_type.update_attributes(params[:work_order_type])
          format.html { redirect_to @work_order_type,
                        notice: (crud_notice('updated', @work_order_type) + "#{undo_link(@work_order_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /work_order_types/1
    # DELETE /work_order_types/1.json
    def destroy
      @work_order_type = WorkOrderType.find(params[:id])

      respond_to do |format|
        if @work_order_type.destroy
          format.html { redirect_to work_order_types_url,
                      notice: (crud_notice('destroyed', @work_order_type) + "#{undo_link(@work_order_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to work_order_types_url, alert: "#{@work_order_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @work_order_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      WorkOrderType.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
