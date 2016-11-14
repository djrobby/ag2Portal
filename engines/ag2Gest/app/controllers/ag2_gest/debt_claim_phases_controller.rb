require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimPhasesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /debt_claim_phases
    # GET /debt_claim_phases.json
    def index
      manage_filter_state
      @debt_claim_phases = DebtClaimPhase.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claim_phases }
        format.js
      end
    end

    # GET /debt_claim_phases/1
    # GET /debt_claim_phases/1.json
    def show
      @breadcrumb = 'read'
      @debt_claim_phase = DebtClaimPhase.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim_phase }
      end
    end

    # GET /debt_claim_phases/new
    # GET /debt_claim_phases/new.json
    def new
      @breadcrumb = 'create'
      @debt_claim_phase = DebtClaimPhase.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim_phase }
      end
    end

    # GET /debt_claim_phases/1/edit
    def edit
      @breadcrumb = 'update'
      @debt_claim_phase = DebtClaimPhase.find(params[:id])
    end

    # POST /debt_claim_phases
    # POST /debt_claim_phases.json
    def create
      @breadcrumb = 'create'
      @debt_claim_phase = DebtClaimPhase.new(params[:debt_claim_phase])
      @debt_claim_phase.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim_phase.save
          format.html { redirect_to @debt_claim_phase, notice: crud_notice('created', @debt_claim_phase) }
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
      @breadcrumb = 'update'
      @debt_claim_phase = DebtClaimPhase.find(params[:id])
      @debt_claim_phase.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim_phase.update_attributes(params[:debt_claim_phase])
          format.html { redirect_to @debt_claim_phase,
                        notice: (crud_notice('updated', @debt_claim_phase) + "#{undo_link(@debt_claim_phase)}").html_safe }
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

      respond_to do |format|
        if @debt_claim_phase.destroy
          format.html { redirect_to debt_claim_phases_url,
                      notice: (crud_notice('destroyed', @debt_claim_phase) + "#{undo_link(@debt_claim_phase)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to debt_claim_phases_url, alert: "#{@debt_claim_phase.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @debt_claim_phase.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      DebtClaimPhase.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
