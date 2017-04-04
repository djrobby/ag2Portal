require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillsToFilesController < ApplicationController
    # GET /bills_to_files
    # GET /bills_to_files.json
    def index
      @bills_to_files = Invoice.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @bills_to_files }
      end
    end

    # GET /bills_to_files/1
    # GET /bills_to_files/1.json
    def show
      @bills_to_file = Invoice.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @bills_to_file }
      end
    end

    # GET /bills_to_files/new
    # GET /bills_to_files/new.json
    def new
      @bills_to_file = Invoice.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @bills_to_file }
      end
    end

    # GET /bills_to_files/1/edit
    def edit
      @bills_to_file = Invoice.find(params[:id])
    end

    # POST /bills_to_files
    # POST /bills_to_files.json
    def create
      @bills_to_file = Invoice.new(params[:bills_to_file])

      respond_to do |format|
        if @bills_to_file.save
          format.html { redirect_to @bills_to_file, notice: 'Bills to file was successfully created.' }
          format.json { render json: @bills_to_file, status: :created, location: @bills_to_file }
        else
          format.html { render action: "new" }
          format.json { render json: @bills_to_file.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /bills_to_files/1
    # PUT /bills_to_files/1.json
    def update
      @bills_to_file = Invoice.find(params[:id])

      respond_to do |format|
        if @bills_to_file.update_attributes(params[:bills_to_file])
          format.html { redirect_to @bills_to_file, notice: 'Bills to file was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @bills_to_file.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /bills_to_files/1
    # DELETE /bills_to_files/1.json
    def destroy
      @bills_to_file = Invoice.find(params[:id])
      @bills_to_file.destroy

      respond_to do |format|
        format.html { redirect_to bills_to_files_url }
        format.json { head :no_content }
      end
    end
  end
end
