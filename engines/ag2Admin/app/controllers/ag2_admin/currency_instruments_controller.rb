require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CurrencyInstrumentsController < ApplicationController
    # GET /currency_instruments
    # GET /currency_instruments.json
    def index
      @currency_instruments = CurrencyInstrument.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @currency_instruments }
      end
    end
  
    # GET /currency_instruments/1
    # GET /currency_instruments/1.json
    def show
      @currency_instrument = CurrencyInstrument.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @currency_instrument }
      end
    end
  
    # GET /currency_instruments/new
    # GET /currency_instruments/new.json
    def new
      @currency_instrument = CurrencyInstrument.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @currency_instrument }
      end
    end
  
    # GET /currency_instruments/1/edit
    def edit
      @currency_instrument = CurrencyInstrument.find(params[:id])
    end
  
    # POST /currency_instruments
    # POST /currency_instruments.json
    def create
      @currency_instrument = CurrencyInstrument.new(params[:currency_instrument])
  
      respond_to do |format|
        if @currency_instrument.save
          format.html { redirect_to @currency_instrument, notice: 'Currency instrument was successfully created.' }
          format.json { render json: @currency_instrument, status: :created, location: @currency_instrument }
        else
          format.html { render action: "new" }
          format.json { render json: @currency_instrument.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /currency_instruments/1
    # PUT /currency_instruments/1.json
    def update
      @currency_instrument = CurrencyInstrument.find(params[:id])
  
      respond_to do |format|
        if @currency_instrument.update_attributes(params[:currency_instrument])
          format.html { redirect_to @currency_instrument, notice: 'Currency instrument was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @currency_instrument.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /currency_instruments/1
    # DELETE /currency_instruments/1.json
    def destroy
      @currency_instrument = CurrencyInstrument.find(params[:id])
      @currency_instrument.destroy
  
      respond_to do |format|
        format.html { redirect_to currency_instruments_url }
        format.json { head :no_content }
      end
    end
  end
end
