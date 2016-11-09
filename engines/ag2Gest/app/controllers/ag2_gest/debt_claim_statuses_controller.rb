require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimStatusesController < ApplicationController
    # GET /debt_claim_statuses
    # GET /debt_claim_statuses.json
    def index
      @debt_claim_statuses = DebtClaimStatus.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claim_statuses }
      end
    end
  
    # GET /debt_claim_statuses/1
    # GET /debt_claim_statuses/1.json
    def show
      @debt_claim_status = DebtClaimStatus.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim_status }
      end
    end
  
    # GET /debt_claim_statuses/new
    # GET /debt_claim_statuses/new.json
    def new
      @debt_claim_status = DebtClaimStatus.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim_status }
      end
    end
  
    # GET /debt_claim_statuses/1/edit
    def edit
      @debt_claim_status = DebtClaimStatus.find(params[:id])
    end
  
    # POST /debt_claim_statuses
    # POST /debt_claim_statuses.json
    def create
      @debt_claim_status = DebtClaimStatus.new(params[:debt_claim_status])
  
      respond_to do |format|
        if @debt_claim_status.save
          format.html { redirect_to @debt_claim_status, notice: 'Debt claim status was successfully created.' }
          format.json { render json: @debt_claim_status, status: :created, location: @debt_claim_status }
        else
          format.html { render action: "new" }
          format.json { render json: @debt_claim_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /debt_claim_statuses/1
    # PUT /debt_claim_statuses/1.json
    def update
      @debt_claim_status = DebtClaimStatus.find(params[:id])
  
      respond_to do |format|
        if @debt_claim_status.update_attributes(params[:debt_claim_status])
          format.html { redirect_to @debt_claim_status, notice: 'Debt claim status was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @debt_claim_status.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /debt_claim_statuses/1
    # DELETE /debt_claim_statuses/1.json
    def destroy
      @debt_claim_status = DebtClaimStatus.find(params[:id])
      @debt_claim_status.destroy
  
      respond_to do |format|
        format.html { redirect_to debt_claim_statuses_url }
        format.json { head :no_content }
      end
    end
  end
end
