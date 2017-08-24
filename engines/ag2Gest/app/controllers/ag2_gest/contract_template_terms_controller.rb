require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractTemplateTermsController < ApplicationController
    # GET /contract_template_terms
    # GET /contract_template_terms.json
    def index
      @contract_template_terms = ContractTemplateTerm.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contract_template_terms }
      end
    end
  
    # GET /contract_template_terms/1
    # GET /contract_template_terms/1.json
    def show
      @contract_template_term = ContractTemplateTerm.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contract_template_term }
      end
    end
  
    # GET /contract_template_terms/new
    # GET /contract_template_terms/new.json
    def new
      @contract_template_term = ContractTemplateTerm.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contract_template_term }
      end
    end
  
    # GET /contract_template_terms/1/edit
    def edit
      @contract_template_term = ContractTemplateTerm.find(params[:id])
    end
  
    # POST /contract_template_terms
    # POST /contract_template_terms.json
    def create
      @contract_template_term = ContractTemplateTerm.new(params[:contract_template_term])
  
      respond_to do |format|
        if @contract_template_term.save
          format.html { redirect_to @contract_template_term, notice: 'Contract template term was successfully created.' }
          format.json { render json: @contract_template_term, status: :created, location: @contract_template_term }
        else
          format.html { render action: "new" }
          format.json { render json: @contract_template_term.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /contract_template_terms/1
    # PUT /contract_template_terms/1.json
    def update
      @contract_template_term = ContractTemplateTerm.find(params[:id])
  
      respond_to do |format|
        if @contract_template_term.update_attributes(params[:contract_template_term])
          format.html { redirect_to @contract_template_term, notice: 'Contract template term was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contract_template_term.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /contract_template_terms/1
    # DELETE /contract_template_terms/1.json
    def destroy
      @contract_template_term = ContractTemplateTerm.find(params[:id])
      @contract_template_term.destroy
  
      respond_to do |format|
        format.html { redirect_to contract_template_terms_url }
        format.json { head :no_content }
      end
    end
  end
end
