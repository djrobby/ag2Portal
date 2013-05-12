require_dependency "ag2_human/application_controller"

module Ag2Human
  class TimeRecordsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /time_records
    # GET /time_records.json
    def index
      worker = params[:Worker]
      from = params[:From]
      to = params[:To]
      type = params[:Type]
      code = params[:Code]

      # Must use Sunspot index always for update (reindex) current data (at console, use Sunspot.commit!)
      TimeRecord.index

      @search = TimeRecord.search do
        if !worker.blank?
          with :worker_id, worker
        end
        if !from.blank?
          any_of do
            with(:timerecord_date).greater_than(from)
            with :timerecord_date, from
          end
        end
        if !to.blank?
          any_of do
            with(:timerecord_date).less_than(to)
            with :timerecord_date, to
          end
        end
        if !type.blank?
          with :timerecord_type_id, type
        end
        if !code.blank?
          with :timerecord_code_id, code
        end
        order_by :timerecord_date, :desc
        order_by :timerecord_time, :desc
        paginate :page => params[:page] || 1, :per_page => 30
      end
      #@time_records = @search.results.sort_by{ |record| [ record.timerecord_date, record.timerecord_time ] }
      @time_records = @search.results
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @time_records }
      end
    end
  
    # GET /time_records/1
    # GET /time_records/1.json
    def show
      @breadcrumb = 'read'
      @time_record = TimeRecord.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @time_record }
      end
    end
  
    # GET /time_records/new
    # GET /time_records/new.json
    def new
      @breadcrumb = 'create'
      @time_record = TimeRecord.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @time_record }
      end
    end
  
    # GET /time_records/1/edit
    def edit
      @breadcrumb = 'update'
      @time_record = TimeRecord.find(params[:id])
    end
  
    # POST /time_records
    # POST /time_records.json
    def create
      @breadcrumb = 'create'
      @time_record = TimeRecord.new(params[:time_record])
      @time_record.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @time_record.save
          format.html { redirect_to @time_record, notice: I18n.t('activerecord.successful.messages.created', :model => @time_record.class.model_name.human) }
          format.json { render json: @time_record, status: :created, location: @time_record }
        else
          format.html { render action: "new" }
          format.json { render json: @time_record.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /time_records/1
    # PUT /time_records/1.json
    def update
      @breadcrumb = 'update'
      @time_record = TimeRecord.find(params[:id])
      @time_record.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @time_record.update_attributes(params[:time_record])
          format.html { redirect_to @time_record, notice: I18n.t('activerecord.successful.messages.updated', :model => @time_record.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @time_record.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /time_records/1
    # DELETE /time_records/1.json
    def destroy
      @time_record = TimeRecord.find(params[:id])
      @time_record.destroy
  
      respond_to do |format|
        format.html { redirect_to time_records_url }
        format.json { head :no_content }
      end
    end
  end
end
