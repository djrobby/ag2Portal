require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class DebtClaimStatusesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /debt_claim_statuses
    # GET /debt_claim_statuses.json
    def index
      manage_filter_state
      @debt_claim_statuses = DebtClaimStatus.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @debt_claim_statuses }
        format.js
      end
    end

    # GET /debt_claim_statuses/1
    # GET /debt_claim_statuses/1.json
    def show
      @breadcrumb = 'read'
      @debt_claim_status = DebtClaimStatus.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @debt_claim_status }
      end
    end

    # GET /debt_claim_statuses/new
    # GET /debt_claim_statuses/new.json
    def new
      @breadcrumb = 'create'
      @debt_claim_status = DebtClaimStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @debt_claim_status }
      end
    end

    # GET /debt_claim_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @debt_claim_status = DebtClaimStatus.find(params[:id])
    end

    # POST /debt_claim_statuses
    # POST /debt_claim_statuses.json
    def create
      @breadcrumb = 'create'
      @debt_claim_status = DebtClaimStatus.new(params[:debt_claim_status])
      @debt_claim_status.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim_status.save
          format.html { redirect_to @debt_claim_status, notice: crud_notice('created', @debt_claim_status) }
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
      @breadcrumb = 'update'
      @debt_claim_status = DebtClaimStatus.find(params[:id])
      @debt_claim_status.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @debt_claim_status.update_attributes(params[:debt_claim_status])
          format.html { redirect_to @debt_claim_status,
                        notice: (crud_notice('updated', @debt_claim_status) + "#{undo_link(@debt_claim_status)}").html_safe }
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

      respond_to do |format|
        if @debt_claim_status.destroy
          format.html { redirect_to debt_claim_statuses_url,
                      notice: (crud_notice('destroyed', @debt_claim_status) + "#{undo_link(@debt_claim_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to debt_claim_statuses_url, alert: "#{@debt_claim_status.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @debt_claim_status.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      DebtClaimStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
