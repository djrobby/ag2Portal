require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class InvoiceStatusesController < ApplicationController

    helper_method :sort_column
    before_filter :authenticate_user!
    load_and_authorize_resource

    # GET /invoice_statuses
    # GET /invoice_statuses.json
    def index
      manage_filter_state
      @invoice_statuses = InvoiceStatus.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoice_statuses }
        format.js
      end
    end

    # GET /invoice_statuses/1
    # GET /invoice_statuses/1.json
    def show
      @breadcrumb = 'read'
      @invoice_status = InvoiceStatus.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @invoice_status }
      end
    end

    # GET /invoice_statuses/new
    # GET /invoice_statuses/new.json
    def new

      @breadcrumb = 'create'
      @invoice_status = InvoiceStatus.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice_status }
      end
    end

    # GET /invoice_statuses/1/edit
    def edit
      @breadcrumb = 'update'
      @invoice_status = InvoiceStatus.find(params[:id])
    end

    # POST /invoice_statuses
    # POST /invoice_statuses.json
    def create
      @breadcrumb = 'create'
      @invoice_status = InvoiceStatus.new(params[:invoice_status])
      @invoice_status.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @invoice_status.save
          format.html { redirect_to @invoice_status, notice: t('activerecord.attributes.invoice_status.create') }
          format.json { render json: @invoice_status, status: :created, location: @invoice_status }
        else
          format.html { render action: "new" }
          format.json { render json: @invoice_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /invoice_statuses/1
    # PUT /invoice_statuses/1.json
    def update
      @breadcrumb = 'update'
      @invoice_status = InvoiceStatus.find(params[:id])
      @invoice_status.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @invoice_status.update_attributes(params[:invoice_status])
          format.html { redirect_to @invoice_status, notice: t('activerecord.attributes.invoice_status.successfully') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @invoice_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /invoice_statuses/1
    # DELETE /invoice_statuses/1.json
    def destroy
      @invoice_status = InvoiceStatus.find(params[:id])
      @invoice_status.destroy

      respond_to do |format|
        format.html { redirect_to invoice_statuses_url }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      InvoiceStatus.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
