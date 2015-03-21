require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class AccountingGroupsController < ApplicationController
    # GET /accounting_groups
    # GET /accounting_groups.json
    def index
      @accounting_groups = AccountingGroup.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @accounting_groups }
      end
    end
  
    # GET /accounting_groups/1
    # GET /accounting_groups/1.json
    def show
      @accounting_group = AccountingGroup.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @accounting_group }
      end
    end
  
    # GET /accounting_groups/new
    # GET /accounting_groups/new.json
    def new
      @accounting_group = AccountingGroup.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @accounting_group }
      end
    end
  
    # GET /accounting_groups/1/edit
    def edit
      @accounting_group = AccountingGroup.find(params[:id])
    end
  
    # POST /accounting_groups
    # POST /accounting_groups.json
    def create
      @accounting_group = AccountingGroup.new(params[:accounting_group])
  
      respond_to do |format|
        if @accounting_group.save
          format.html { redirect_to @accounting_group, notice: 'Accounting group was successfully created.' }
          format.json { render json: @accounting_group, status: :created, location: @accounting_group }
        else
          format.html { render action: "new" }
          format.json { render json: @accounting_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /accounting_groups/1
    # PUT /accounting_groups/1.json
    def update
      @accounting_group = AccountingGroup.find(params[:id])
  
      respond_to do |format|
        if @accounting_group.update_attributes(params[:accounting_group])
          format.html { redirect_to @accounting_group, notice: 'Accounting group was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @accounting_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /accounting_groups/1
    # DELETE /accounting_groups/1.json
    def destroy
      @accounting_group = AccountingGroup.find(params[:id])
      @accounting_group.destroy
  
      respond_to do |format|
        format.html { redirect_to accounting_groups_url }
        format.json { head :no_content }
      end
    end
  end
end
