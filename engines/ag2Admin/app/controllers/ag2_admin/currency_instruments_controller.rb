require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CurrencyInstrumentsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /currency_instruments
    # GET /currency_instruments.json
    def index
      manage_filter_state
      @currency_instruments = CurrencyInstrument.includes(:currency).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @currency_instruments }
        format.js
      end
    end

    # GET /currency_instruments/1
    # GET /currency_instruments/1.json
    def show
      @breadcrumb = 'read'
      @currency_instrument = CurrencyInstrument.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @currency_instrument }
      end
    end

    # GET /currency_instruments/new
    # GET /currency_instruments/new.json
    def new
      @breadcrumb = 'create'
      @currency_instrument = CurrencyInstrument.new
      @minor_unit = 6

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @currency_instrument }
      end
    end

    # GET /currency_instruments/1/edit
    def edit
      @breadcrumb = 'update'
      @currency_instrument = CurrencyInstrument.find(params[:id])
      @minor_unit = @currency_instrument.currency.minor_unit
    end

    # POST /currency_instruments
    # POST /currency_instruments.json
    def create
      @breadcrumb = 'create'
      @currency_instrument = CurrencyInstrument.new(params[:currency_instrument])
      @currency_instrument.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @currency_instrument.save
          format.html { redirect_to @currency_instrument, notice: crud_notice('created', @currency_instrument) }
          format.json { render json: @currency_instrument, status: :created, location: @currency_instrument }
        else
          @minor_unit = 6
          format.html { render action: "new" }
          format.json { render json: @currency_instrument.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /currency_instruments/1
    # PUT /currency_instruments/1.json
    def update
      @breadcrumb = 'update'
      @currency_instrument = CurrencyInstrument.find(params[:id])
      @currency_instrument.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @currency_instrument.update_attributes(params[:currency_instrument])
          format.html { redirect_to @currency_instrument,
                        notice: (crud_notice('updated', @currency_instrument) + "#{undo_link(@currency_instrument)}").html_safe }
          format.json { head :no_content }
        else
          @minor_unit = @currency_instrument.currency.minor_unit
          format.html { render action: "edit" }
          format.json { render json: @currency_instrument.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /currency_instruments/1
    # DELETE /currency_instruments/1.json
    def destroy
      @currency_instrument = CurrencyInstrument.find(params[:id])

      respond_to do |format|
        if @currency_instrument.destroy
          format.html { redirect_to currency_instruments_url,
                      notice: (crud_notice('destroyed', @currency_instrument) + "#{undo_link(@currency_instrument)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to currency_instruments_url, alert: "#{@currency_instrument.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @currency_instrument.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      if params[:sort] == 'currency_id'
        "currency_id, value_i"
      else
        CurrencyInstrument.column_names.include?(params[:sort]) ? params[:sort] : "currency_id, id"
      end
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
