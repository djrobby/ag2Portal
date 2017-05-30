require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class CurrenciesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /currencies
    # GET /currencies.json
    def index
      manage_filter_state
      @currencies = Currency.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @currencies }
        format.js
      end
    end

    # GET /currencies/1
    # GET /currencies/1.json
    def show
      @breadcrumb = 'read'
      @currency = Currency.find(params[:id])
      @currency_instruments = @currency.currency_instruments.by_value

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @currency }
      end
    end

    # GET /currencies/new
    # GET /currencies/new.json
    def new
      @breadcrumb = 'create'
      @currency = Currency.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @currency }
      end
    end

    # GET /currencies/1/edit
    def edit
      @breadcrumb = 'update'
      @currency = Currency.find(params[:id])
    end

    # POST /currencies
    # POST /currencies.json
    def create
      @breadcrumb = 'create'
      @currency = Currency.new(params[:currency])
      @currency.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @currency.save
          format.html { redirect_to @currency, notice: crud_notice('created', @currency) }
          format.json { render json: @currency, status: :created, location: @currency }
        else
          format.html { render action: "new" }
          format.json { render json: @currency.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /currencies/1
    # PUT /currencies/1.json
    def update
      @breadcrumb = 'update'
      @currency = Currency.find(params[:id])
      @currency.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @currency.update_attributes(params[:currency])
          format.html { redirect_to @currency,
                        notice: (crud_notice('updated', @currency) + "#{undo_link(@currency)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @currency.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /currencies/1
    # DELETE /currencies/1.json
    def destroy
      @currency = Currency.find(params[:id])

      respond_to do |format|
        if @currency.destroy
          format.html { redirect_to currencies_url,
                      notice: (crud_notice('destroyed', @currency) + "#{undo_link(@currency)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to currencies_url, alert: "#{@currency.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @currency.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Currency.column_names.include?(params[:sort]) ? params[:sort] : "alphabetic_code"
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
