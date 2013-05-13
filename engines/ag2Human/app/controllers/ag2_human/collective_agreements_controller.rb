require_dependency "ag2_human/application_controller"

module Ag2Human
  class CollectiveAgreementsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /collective_agreements
    # GET /collective_agreements.json
    def index
      @collective_agreements = CollectiveAgreement.paginate(:page => params[:page], :per_page => per_page).order('ca_code')
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @collective_agreements }
      end
    end
  
    # GET /collective_agreements/1
    # GET /collective_agreements/1.json
    def show
      @breadcrumb = 'read'
      @collective_agreement = CollectiveAgreement.find(params[:id])
      @workers = @collective_agreement.workers
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @collective_agreement }
      end
    end
  
    # GET /collective_agreements/new
    # GET /collective_agreements/new.json
    def new
      @breadcrumb = 'create'
      @collective_agreement = CollectiveAgreement.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @collective_agreement }
      end
    end
  
    # GET /collective_agreements/1/edit
    def edit
      @breadcrumb = 'update'
      @collective_agreement = CollectiveAgreement.find(params[:id])
    end
  
    # POST /collective_agreements
    # POST /collective_agreements.json
    def create
      @breadcrumb = 'create'
      @collective_agreement = CollectiveAgreement.new(params[:collective_agreement])
      @collective_agreement.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @collective_agreement.save
          format.html { redirect_to @collective_agreement, notice: I18n.t('activerecord.successful.messages.created', :model => @collective_agreement.class.model_name.human) }
          format.json { render json: @collective_agreement, status: :created, location: @collective_agreement }
        else
          format.html { render action: "new" }
          format.json { render json: @collective_agreement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /collective_agreements/1
    # PUT /collective_agreements/1.json
    def update
      @breadcrumb = 'update'
      @collective_agreement = CollectiveAgreement.find(params[:id])
      @collective_agreement.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @collective_agreement.update_attributes(params[:collective_agreement])
          format.html { redirect_to @collective_agreement, notice: I18n.t('activerecord.successful.messages.updated', :model => @collective_agreement.class.model_name.human) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @collective_agreement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /collective_agreements/1
    # DELETE /collective_agreements/1.json
    def destroy
      @collective_agreement = CollectiveAgreement.find(params[:id])
      @collective_agreement.destroy
  
      respond_to do |format|
        format.html { redirect_to collective_agreements_url }
        format.json { head :no_content }
      end
    end
  end
end
