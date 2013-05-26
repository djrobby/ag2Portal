require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class TechniciansController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /technicians
    # GET /technicians.json
    def index
      @technicians = Technician.paginate(:page => params[:page], :per_page => per_page).order('name')
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @technicians }
      end
    end
  
    # GET /technicians/1
    # GET /technicians/1.json
    def show
      @breadcrumb = 'read'
      @technician = Technician.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @technician }
      end
    end
  
    # GET /technicians/new
    # GET /technicians/new.json
    def new
      @breadcrumb = 'create'
      @technician = Technician.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @technician }
      end
    end
  
    # GET /technicians/1/edit
    def edit
      @breadcrumb = 'update'
      @technician = Technician.find(params[:id])
    end
  
    # POST /technicians
    # POST /technicians.json
    def create
      @breadcrumb = 'create'
      @technician = Technician.new(params[:technician])
      @technician.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @technician.save
          format.html { redirect_to @technician, notice: I18n.t('activerecord.successful.messages.created', :model => @technician.class.model_name.human) }
          format.json { render json: @technician, status: :created, location: @technician }
        else
          format.html { render action: "new" }
          format.json { render json: @technician.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /technicians/1
    # PUT /technicians/1.json
    def update
      @breadcrumb = 'update'
      @technician = Technician.find(params[:id])
      @technician.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @technician.update_attributes(params[:technician])
          format.html { redirect_to @technician, notice: I18n.t('activerecord.successful.messages.updated', :model => @technician.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @technician.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /technicians/1
    # DELETE /technicians/1.json
    def destroy
      @technician = Technician.find(params[:id])
      @technician.destroy
  
      respond_to do |format|
        format.html { redirect_to technicians_url }
        format.json { head :no_content }
      end
    end
  end
end
