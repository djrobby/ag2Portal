require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillableItemsController < ApplicationController
    # GET /billable_items
    # GET /billable_items.json
    def index
      @billable_items = BillableItem.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billable_items }
      end
    end
  
    # GET /billable_items/1
    # GET /billable_items/1.json
    def show
      @billable_item = BillableItem.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billable_item }
      end
    end
  
    # GET /billable_items/new
    # GET /billable_items/new.json
    def new
      @billable_item = BillableItem.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billable_item }
      end
    end
  
    # GET /billable_items/1/edit
    def edit
      @billable_item = BillableItem.find(params[:id])
    end
  
    # POST /billable_items
    # POST /billable_items.json
    def create
      @billable_item = BillableItem.new(params[:billable_item])
  
      respond_to do |format|
        if @billable_item.save
          format.html { redirect_to @billable_item, notice: 'Billable item was successfully created.' }
          format.json { render json: @billable_item, status: :created, location: @billable_item }
        else
          format.html { render action: "new" }
          format.json { render json: @billable_item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /billable_items/1
    # PUT /billable_items/1.json
    def update
      @billable_item = BillableItem.find(params[:id])
  
      respond_to do |format|
        if @billable_item.update_attributes(params[:billable_item])
          format.html { redirect_to @billable_item, notice: 'Billable item was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billable_item.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /billable_items/1
    # DELETE /billable_items/1.json
    def destroy
      @billable_item = BillableItem.find(params[:id])
      @billable_item.destroy
  
      respond_to do |format|
        format.html { redirect_to billable_items_url }
        format.json { head :no_content }
      end
    end
  end
end
