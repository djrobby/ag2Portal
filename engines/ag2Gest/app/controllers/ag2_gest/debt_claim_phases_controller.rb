require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimPhasesController < ApplicationController
    # GET /debt_claim_phases
    # GET /debt_claim_phases.json
    def index
      @debt_claim_phases = DebtClaimPhase.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claim_phases }
      end
    end
  
    # GET /debt_claim_phases/1
    # GET /debt_claim_phases/1.json
    def show
      @debt_claim_phase = DebtClaimPhase.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim_phase }
      end
    end
  
    # GET /debt_claim_phases/new
    # GET /debt_claim_phases/new.json
    def new
      @debt_claim_phase = DebtClaimPhase.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim_phase }
      end
    end
  
    # GET /debt_claim_phases/1/edit
    def edit
      @debt_claim_phase = DebtClaimPhase.find(params[:id])
    end
  
    # POST /debt_claim_phases
    # POST /debt_claim_phases.json
    def create
      @debt_claim_phase = DebtClaimPhase.new(params[:debt_claim_phase])
  
      respond_to do |format|
        if @debt_claim_phase.save
          format.html { redirect_to @debt_claim_phase, notice: 'Debt claim phase was successfully created.' }
          format.json { render json: @debt_claim_phase, status: :created, location: @debt_claim_phase }
        else
          format.html { render action: "new" }
          format.json { render json: @debt_claim_phase.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /debt_claim_phases/1
    # PUT /debt_claim_phases/1.json
    def update
      @debt_claim_phase = DebtClaimPhase.find(params[:id])
  
      respond_to do |format|
        if @debt_claim_phase.update_attributes(params[:debt_claim_phase])
          format.html { redirect_to @debt_claim_phase, notice: 'Debt claim phase was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @debt_claim_phase.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /debt_claim_phases/1
    # DELETE /debt_claim_phases/1.json
    def destroy
      @debt_claim_phase = DebtClaimPhase.find(params[:id])
      @debt_claim_phase.destroy
  
      respond_to do |format|
        format.html { redirect_to debt_claim_phases_url }
        format.json { head :no_content }
      end
    end
  end
end
