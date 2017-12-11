require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CashMovementsController < ApplicationController
    # GET /cash_movements
    # GET /cash_movements.json
    def index
      @cash_movements = CashMovement.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @cash_movements }
      end
    end
  
    # GET /cash_movements/1
    # GET /cash_movements/1.json
    def show
      @cash_movement = CashMovement.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @cash_movement }
      end
    end
  
    # GET /cash_movements/new
    # GET /cash_movements/new.json
    def new
      @cash_movement = CashMovement.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @cash_movement }
      end
    end
  
    # GET /cash_movements/1/edit
    def edit
      @cash_movement = CashMovement.find(params[:id])
    end
  
    # POST /cash_movements
    # POST /cash_movements.json
    def create
      @cash_movement = CashMovement.new(params[:cash_movement])
  
      respond_to do |format|
        if @cash_movement.save
          format.html { redirect_to @cash_movement, notice: 'Cash movement was successfully created.' }
          format.json { render json: @cash_movement, status: :created, location: @cash_movement }
        else
          format.html { render action: "new" }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /cash_movements/1
    # PUT /cash_movements/1.json
    def update
      @cash_movement = CashMovement.find(params[:id])
  
      respond_to do |format|
        if @cash_movement.update_attributes(params[:cash_movement])
          format.html { redirect_to @cash_movement, notice: 'Cash movement was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @cash_movement.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /cash_movements/1
    # DELETE /cash_movements/1.json
    def destroy
      @cash_movement = CashMovement.find(params[:id])
      @cash_movement.destroy
  
      respond_to do |format|
        format.html { redirect_to cash_movements_url }
        format.json { head :no_content }
      end
    end
  end
end
