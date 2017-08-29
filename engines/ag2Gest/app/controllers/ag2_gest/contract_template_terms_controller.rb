require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ContractTemplateTermsController < ApplicationController

    helper_method :sort_column
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /contract_template_terms
    # GET /contract_template_terms.json
    def index
      @contract_template_terms = ContractTemplateTerm.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contract_template_terms }
        format.js
      end
    end
  
    # GET /contract_template_terms/1
    # GET /contract_template_terms/1.json
    def show
      @breadcrumb = 'read'
      @contract_template_term = ContractTemplateTerm.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contract_template_term }
      end
    end
  
    # GET /contract_template_terms/new
    # GET /contract_template_terms/new.json
    def new
      @breadcrumb = 'create'
      @contract_template_term = ContractTemplateTerm.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contract_template_terms }
      end
    end
  
    # GET /contract_template_terms/1/edit
    def edit
      @breadcrumb = 'update'
      @contract_template_terms = ContractTemplateTerm.find(params[:id])
    end
  
    # POST /contract_template_terms
    # POST /contract_template_terms.json
    def create
      @breadcrumb = 'create'
      @contract_template_term = ContractTemplateTerm.new(params[:contract_template_term])
      @contract_template_term.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @contract_template_term.save
          format.html { redirect_to @contract_template_term, notice: crud_notice('created', @contract_template_term) }
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
      @breadcrumb = 'update'
      @contract_template_term = ContractTemplateTerm.find(params[:id])
      @contract_template_term.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contract_template_term.update_attributes(params[:contract_template_term])
          format.html { redirect_to @contract_template_term,
                        notice: (crud_notice('updated', @contract_template_term) + "#{undo_link(@contract_template_term)}").html_safe }
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
      @contract_template_terms = ContractTemplateTerm.find(params[:id])

      respond_to do |format|
        if @contract_template_terms.destroy
          format.html { redirect_to contract_template_terms_url,
                      notice: (crud_notice('destroyed', @contract_template_term) + "#{undo_link(@contract_template_term)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to contract_template_terms_url, alert: "#{@contract_template_term.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @contract_template_terms.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ContractTemplateTerm.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
