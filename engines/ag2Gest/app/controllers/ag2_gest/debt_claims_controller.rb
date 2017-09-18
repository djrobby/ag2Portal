require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /debt_claims
    # GET /debt_claims.json
    def index
      manage_filter_state
      @debt_claims = DebtClaim.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claims }
      end
    end

    # GET /debt_claims/1
    # GET /debt_claims/1.json
    def show
      @breadcrumb = 'read'
      @debt_claim = DebtClaim.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim }
      end
    end

    # GET /debt_claims/new
    # GET /debt_claims/new.json
    def new
      @breadcrumb = 'create'
      @debt_claim = DebtClaim.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim }
      end
    end

    # GET /debt_claims/1/edit
    def edit
      @breadcrumb = 'update'
      @debt_claim = DebtClaim.find(params[:id])
    end

    # POST /debt_claims
    # POST /debt_claims.json
    def create
      @breadcrumb = 'create'
      @debt_claim = DebtClaim.new(params[:debt_claim])
      @debt_claim.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim.save
          format.html { redirect_to @debt_claim, notice: crud_notice('created', @debt_claim) }
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
      @breadcrumb = 'update'
      @debt_claim = DebtClaim.find(params[:id])
      @debt_claim.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim.update_attributes(params[:debt_claim])
          format.html { redirect_to @debt_claim,
                        notice: (crud_notice('updated', @debt_claim) + "#{undo_link(@debt_claim)}").html_safe }
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

      respond_to do |format|
        if @debt_claim.destroy
          format.html { redirect_to debt_claims_url,
                      notice: (crud_notice('destroyed', @debt_claim) + "#{undo_link(@debt_claim)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to debt_claims_url, alert: "#{@debt_claim.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @debt_claim.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Keeps filter state
    def manage_filter_state
    end
  end
end
