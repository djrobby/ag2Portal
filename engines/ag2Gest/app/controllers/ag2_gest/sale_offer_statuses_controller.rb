require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SaleOfferStatusesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /sale_offer_statuses_statuses
    # GET /sale_offer_statuses_statuses.json
    def index
      manage_filter_state
      @sale_offer_statuses = SaleOfferStatus.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sale_offer_statuses }
        format.js
      end
    end

    # GET /sale_offer_statuses_statuses/1
    # GET /sale_offer_statuses_statuses/1.json
    def show
      @breadcrumb = 'read'
      @sale_offer_status = SaleOfferStatus.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sale_offer_status }
      end
    end

    # GET /sale_offer_statuses_statuses/new
    # GET /sale_offer_statuses_statuses/new.json
    def new

      @breadcrumb = 'create'
      @sale_offer_status = SaleOfferStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sale_offer_status }
      end

    end

    # GET /sale_offer_statuses_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @sale_offer_status = SaleOfferStatus.find(params[:id])
    end

    # POST /sale_offer_statuses_statuses
    # POST /sale_offer_statuses_statuses.json
    def create
      @breadcrumb = 'create'
      @sale_offer_status = SaleOfferStatus.new(params[:sale_offer_status])

      respond_to do |format|
        if @sale_offer_status.save
          format.html { redirect_to @sale_offer_status, notice: t('activerecord.attributes.sale_offer_status.create') }
          format.json { render json: @sale_offer_status, status: :created, location: @sale_offer_status }
        else
          format.html { render action: "new" }
          format.json { render json: @sale_offer_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /sale_offer_statuses_statuses/1
    # PUT /sale_offer_statuses_statuses/1.json
    def update
      @breadcrumb = 'update'
      @sale_offer_status = SaleOfferStatus.find(params[:id])

      respond_to do |format|
        if @sale_offer_status.update_attributes(params[:sale_offer_status])
          format.html { redirect_to @sale_offer_status,
                        notice: (crud_notice('updated', @sale_offer_status) + "#{undo_link(@sale_offer_status)}").html_safe }
          format.html { redirect_to @sale_offer_status, notice: t('activerecord.attributes.sale_offer_status.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sale_offer_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /sale_offer_statuses_statuses/1
    # DELETE /sale_offer_statuses_statuses/1.json
    def destroy
      @sale_offer_status = SaleOfferStatus.find(params[:id])
      @sale_offer_status.destroy

      respond_to do |format|
        if @sale_offer_status.destroy
          format.html { redirect_to sale_offer_statuses_url,
                      notice: (crud_notice('destroyed', @sale_offer_status) + "#{undo_link(@sale_offer_status)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to sale_offer_statuses_url, alert: "#{@sale_offer_status.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @sale_offer_status.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      SaleOfferStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
