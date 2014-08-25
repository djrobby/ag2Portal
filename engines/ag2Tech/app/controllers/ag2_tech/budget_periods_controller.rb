require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetPeriodsController < ApplicationController
    # GET /budget_periods
    # GET /budget_periods.json
    def index
      @budget_periods = BudgetPeriod.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @budget_periods }
      end
    end
  
    # GET /budget_periods/1
    # GET /budget_periods/1.json
    def show
      @budget_period = BudgetPeriod.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @budget_period }
      end
    end
  
    # GET /budget_periods/new
    # GET /budget_periods/new.json
    def new
      @budget_period = BudgetPeriod.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget_period }
      end
    end
  
    # GET /budget_periods/1/edit
    def edit
      @budget_period = BudgetPeriod.find(params[:id])
    end
  
    # POST /budget_periods
    # POST /budget_periods.json
    def create
      @budget_period = BudgetPeriod.new(params[:budget_period])
  
      respond_to do |format|
        if @budget_period.save
          format.html { redirect_to @budget_period, notice: 'Budget period was successfully created.' }
          format.json { render json: @budget_period, status: :created, location: @budget_period }
        else
          format.html { render action: "new" }
          format.json { render json: @budget_period.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /budget_periods/1
    # PUT /budget_periods/1.json
    def update
      @budget_period = BudgetPeriod.find(params[:id])
  
      respond_to do |format|
        if @budget_period.update_attributes(params[:budget_period])
          format.html { redirect_to @budget_period, notice: 'Budget period was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @budget_period.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /budget_periods/1
    # DELETE /budget_periods/1.json
    def destroy
      @budget_period = BudgetPeriod.find(params[:id])
      @budget_period.destroy
  
      respond_to do |format|
        format.html { redirect_to budget_periods_url }
        format.json { head :no_content }
      end
    end
  end
end
