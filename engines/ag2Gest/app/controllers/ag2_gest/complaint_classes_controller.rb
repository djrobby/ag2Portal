require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ComplaintClassesController < ApplicationController
    # GET /complaint_classes
    # GET /complaint_classes.json
    def index
      @complaint_classes = ComplaintClass.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @complaint_classes }
      end
    end

    # GET /complaint_classes/1
    # GET /complaint_classes/1.json
    def show
      @complaint_class = ComplaintClass.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @complaint_class }
      end
    end

    # GET /complaint_classes/new
    # GET /complaint_classes/new.json
    def new
      @complaint_class = ComplaintClass.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @complaint_class }
      end
    end

    # GET /complaint_classes/1/edit
    def edit
      @complaint_class = ComplaintClass.find(params[:id])
    end

    # POST /complaint_classes
    # POST /complaint_classes.json
    def create
      @complaint_class = ComplaintClass.new(params[:complaint_class])

      respond_to do |format|
        if @complaint_class.save
          format.html { redirect_to @complaint_class, notice: 'Complaint class was successfully created.' }
          format.json { render json: @complaint_class, status: :created, location: @complaint_class }
        else
          format.html { render action: "new" }
          format.json { render json: @complaint_class.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /complaint_classes/1
    # PUT /complaint_classes/1.json
    def update
      @complaint_class = ComplaintClass.find(params[:id])

      respond_to do |format|
        if @complaint_class.update_attributes(params[:complaint_class])
          format.html { redirect_to @complaint_class, notice: 'Complaint class was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @complaint_class.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /complaint_classes/1
    # DELETE /complaint_classes/1.json
    def destroy
      @complaint_class = ComplaintClass.find(params[:id])
      @complaint_class.destroy

      respond_to do |format|
        format.html { redirect_to complaint_classes_url }
        format.json { head :no_content }
      end
    end
  end
end
