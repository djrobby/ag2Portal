require_dependency "ag2_human/application_controller"

module Ag2Human
  class ProfessionalGroupsController < ApplicationController
    # GET /professional_groups
    # GET /professional_groups.json
    def index
      @professional_groups = ProfessionalGroup.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @professional_groups }
      end
    end
  
    # GET /professional_groups/1
    # GET /professional_groups/1.json
    def show
      @breadcrumb = 'read'
      @professional_group = ProfessionalGroup.find(params[:id])
      @workers = @professional_group.workers
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @professional_group }
      end
    end
  
    # GET /professional_groups/new
    # GET /professional_groups/new.json
    def new
      @breadcrumb = 'create'
      @professional_group = ProfessionalGroup.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @professional_group }
      end
    end
  
    # GET /professional_groups/1/edit
    def edit
      @breadcrumb = 'update'
      @professional_group = ProfessionalGroup.find(params[:id])
    end
  
    # POST /professional_groups
    # POST /professional_groups.json
    def create
      @breadcrumb = 'create'
      @professional_group = ProfessionalGroup.new(params[:professional_group])
      @professional_group.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @professional_group.save
          format.html { redirect_to @professional_group, notice: I18n.t('activerecord.successful.messages.created', :model => @professional_group.class.model_name.human) }
          format.json { render json: @professional_group, status: :created, location: @professional_group }
        else
          format.html { render action: "new" }
          format.json { render json: @professional_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /professional_groups/1
    # PUT /professional_groups/1.json
    def update
      @breadcrumb = 'update'
      @professional_group = ProfessionalGroup.find(params[:id])
      @professional_group.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @professional_group.update_attributes(params[:professional_group])
          format.html { redirect_to @professional_group, notice: I18n.t('activerecord.successful.messages.updated', :model => @professional_group.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @professional_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /professional_groups/1
    # DELETE /professional_groups/1.json
    def destroy
      @professional_group = ProfessionalGroup.find(params[:id])
      @professional_group.destroy
  
      respond_to do |format|
        format.html { redirect_to professional_groups_url }
        format.json { head :no_content }
      end
    end
  end
end
