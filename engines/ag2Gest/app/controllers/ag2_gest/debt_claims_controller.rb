require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimsController < ApplicationController
    # GET /debt_claims
    # GET /debt_claims.json
    def index
      @debt_claims = DebtClaim.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claims }
      end
    end
  
    # GET /debt_claims/1
    # GET /debt_claims/1.json
    def show
      @debt_claim = DebtClaim.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim }
      end
    end
  
    # GET /debt_claims/new
    # GET /debt_claims/new.json
    def new
      @debt_claim = DebtClaim.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim }
      end
    end
  
    # GET /debt_claims/1/edit
    def edit
      @debt_claim = DebtClaim.find(params[:id])
    end
  
    # POST /debt_claims
    # POST /debt_claims.json
    def create
      @debt_claim = DebtClaim.new(params[:debt_claim])
  
      respond_to do |format|
        if @debt_claim.save
          format.html { redirect_to @debt_claim, notice: 'Debt claim was successfully created.' }
          format.json { render json: @debt_claim, status: :created, location: @debt_claim }
        else
          format.html { render action: "new" }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /debt_claims/1
    # PUT /debt_claims/1.json
    def update
      @debt_claim = DebtClaim.find(params[:id])
  
      respond_to do |format|
        if @debt_claim.update_attributes(params[:debt_claim])
          format.html { redirect_to @debt_claim, notice: 'Debt claim was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /debt_claims/1
    # DELETE /debt_claims/1.json
    def destroy
      @debt_claim = DebtClaim.find(params[:id])
      @debt_claim.destroy
  
      respond_to do |format|
        format.html { redirect_to debt_claims_url }
        format.json { head :no_content }
      end
    end
  end
end
