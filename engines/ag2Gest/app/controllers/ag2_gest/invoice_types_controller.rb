require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class InvoiceTypesController < ApplicationController
    # GET /invoice_types
    # GET /invoice_types.json
    def index
      @invoice_types = InvoiceType.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoice_types }
      end
    end
  
    # GET /invoice_types/1
    # GET /invoice_types/1.json
    def show
      @invoice_type = InvoiceType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @invoice_type }
      end
    end
  
    # GET /invoice_types/new
    # GET /invoice_types/new.json
    def new
      @invoice_type = InvoiceType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice_type }
      end
    end
  
    # GET /invoice_types/1/edit
    def edit
      @invoice_type = InvoiceType.find(params[:id])
    end
  
    # POST /invoice_types
    # POST /invoice_types.json
    def create
      @invoice_type = InvoiceType.new(params[:invoice_type])
  
      respond_to do |format|
        if @invoice_type.save
          format.html { redirect_to @invoice_type, notice: 'Invoice type was successfully created.' }
          format.json { render json: @invoice_type, status: :created, location: @invoice_type }
        else
          format.html { render action: "new" }
          format.json { render json: @invoice_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /invoice_types/1
    # PUT /invoice_types/1.json
    def update
      @invoice_type = InvoiceType.find(params[:id])
  
      respond_to do |format|
        if @invoice_type.update_attributes(params[:invoice_type])
          format.html { redirect_to @invoice_type, notice: 'Invoice type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @invoice_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /invoice_types/1
    # DELETE /invoice_types/1.json
    def destroy
      @invoice_type = InvoiceType.find(params[:id])
      @invoice_type.destroy
  
      respond_to do |format|
        format.html { redirect_to invoice_types_url }
        format.json { head :no_content }
      end
    end
  end
end
