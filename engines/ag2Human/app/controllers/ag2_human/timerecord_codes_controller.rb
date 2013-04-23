require_dependency "ag2_human/application_controller"

module Ag2Human
  class TimerecordCodesController < ApplicationController
    # GET /timerecord_codes
    # GET /timerecord_codes.json
    def index
      @timerecord_codes = TimerecordCode.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @timerecord_codes }
      end
    end
  
    # GET /timerecord_codes/1
    # GET /timerecord_codes/1.json
    def show
      @breadcrumb = 'read'
      @timerecord_code = TimerecordCode.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @timerecord_code }
      end
    end
  
    # GET /timerecord_codes/new
    # GET /timerecord_codes/new.json
    def new
      @breadcrumb = 'create'
      @timerecord_code = TimerecordCode.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @timerecord_code }
      end
    end
  
    # GET /timerecord_codes/1/edit
    def edit
      @breadcrumb = 'update'
      @timerecord_code = TimerecordCode.find(params[:id])
    end
  
    # POST /timerecord_codes
    # POST /timerecord_codes.json
    def create
      @breadcrumb = 'create'
      @timerecord_code = TimerecordCode.new(params[:timerecord_code])
  
      respond_to do |format|
        if @timerecord_code.save
          format.html { redirect_to @timerecord_code, notice: 'Timerecord code was successfully created.' }
          format.json { render json: @timerecord_code, status: :created, location: @timerecord_code }
        else
          format.html { render action: "new" }
          format.json { render json: @timerecord_code.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /timerecord_codes/1
    # PUT /timerecord_codes/1.json
    def update
      @breadcrumb = 'update'
      @timerecord_code = TimerecordCode.find(params[:id])
  
      respond_to do |format|
        if @timerecord_code.update_attributes(params[:timerecord_code])
          format.html { redirect_to @timerecord_code, notice: 'Timerecord code was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @timerecord_code.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /timerecord_codes/1
    # DELETE /timerecord_codes/1.json
    def destroy
      @timerecord_code = TimerecordCode.find(params[:id])
      @timerecord_code.destroy
  
      respond_to do |format|
        format.html { redirect_to timerecord_codes_url }
        format.json { head :no_content }
      end
    end
  end
end
