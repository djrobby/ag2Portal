require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class DataImportConfigsController < ApplicationController
    # GET /data_import_configs
    # GET /data_import_configs.json
    def index
      @data_import_configs = DataImportConfig.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @data_import_configs }
      end
    end
  
    # GET /data_import_configs/1
    # GET /data_import_configs/1.json
    def show
      @breadcrumb = 'read'
      @data_import_config = DataImportConfig.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @data_import_config }
      end
    end
  
    # GET /data_import_configs/new
    # GET /data_import_configs/new.json
    def new
      @breadcrumb = 'create'
      @data_import_config = DataImportConfig.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @data_import_config }
      end
    end
  
    # GET /data_import_configs/1/edit
    def edit
      @breadcrumb = 'update'
      @data_import_config = DataImportConfig.find(params[:id])
    end
  
    # POST /data_import_configs
    # POST /data_import_configs.json
    def create
      @breadcrumb = 'create'
      @data_import_config = DataImportConfig.new(params[:data_import_config])
      @data_import_config.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @data_import_config.save
          format.html { redirect_to @data_import_config, notice: I18n.t('activerecord.successful.messages.created', :model => @data_import_config.class.model_name.human) }
          format.json { render json: @data_import_config, status: :created, location: @data_import_config }
        else
          format.html { render action: "new" }
          format.json { render json: @data_import_config.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /data_import_configs/1
    # PUT /data_import_configs/1.json
    def update
      @breadcrumb = 'update'
      @data_import_config = DataImportConfig.find(params[:id])
      @data_import_config.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @data_import_config.update_attributes(params[:data_import_config])
          format.html { redirect_to @data_import_config, notice: I18n.t('activerecord.successful.messages.updated', :model => @data_import_config.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @data_import_config.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /data_import_configs/1
    # DELETE /data_import_configs/1.json
    def destroy
      @data_import_config = DataImportConfig.find(params[:id])
      @data_import_config.destroy
  
      respond_to do |format|
        format.html { redirect_to data_import_configs_url }
        format.json { head :no_content }
      end
    end
  end
end
