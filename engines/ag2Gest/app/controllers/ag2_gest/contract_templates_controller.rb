require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractTemplatesController < ApplicationController
    # GET /contract_templates
    # GET /contract_templates.json
    def index
      @contract_templates = ContractTemplate.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contract_templates }
      end
    end
  
    # GET /contract_templates/1
    # GET /contract_templates/1.json
    def show
      @contract_template = ContractTemplate.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contract_template }
      end
    end
  
    # GET /contract_templates/new
    # GET /contract_templates/new.json
    def new
      @contract_template = ContractTemplate.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contract_template }
      end
    end
  
    # GET /contract_templates/1/edit
    def edit
      @contract_template = ContractTemplate.find(params[:id])
    end
  
    # POST /contract_templates
    # POST /contract_templates.json
    def create
      @contract_template = ContractTemplate.new(params[:contract_template])
  
      respond_to do |format|
        if @contract_template.save
          format.html { redirect_to @contract_template, notice: 'Contract template was successfully created.' }
          format.json { render json: @contract_template, status: :created, location: @contract_template }
        else
          format.html { render action: "new" }
          format.json { render json: @contract_template.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /contract_templates/1
    # PUT /contract_templates/1.json
    def update
      @contract_template = ContractTemplate.find(params[:id])
  
      respond_to do |format|
        if @contract_template.update_attributes(params[:contract_template])
          format.html { redirect_to @contract_template, notice: 'Contract template was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contract_template.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /contract_templates/1
    # DELETE /contract_templates/1.json
    def destroy
      @contract_template = ContractTemplate.find(params[:id])
      @contract_template.destroy
  
      respond_to do |format|
        format.html { redirect_to contract_templates_url }
        format.json { head :no_content }
      end
    end
  end
end
