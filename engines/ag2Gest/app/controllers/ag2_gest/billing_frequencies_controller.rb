require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillingFrequenciesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /billing_frequencies
    # GET /billing_frequencies.json
    def index
      manage_filter_state
      @billing_frequencies = BillingFrequency.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billing_frequencies }
        format.js
      end
    end

    # GET /billing_frequencies/1
    # GET /billing_frequencies/1.json
    def show
      @breadcrumb = 'read'
      @billing_frequency = BillingFrequency.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billing_frequency }
      end
    end

    # GET /billing_frequencies/new
    # GET /billing_frequencies/new.json
    def new
      @breadcrumb = 'create'
      @billing_frequency = BillingFrequency.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billing_frequency }
      end
    end

    # GET /billing_frequencies/1/edit
    def edit
      @breadcrumb = 'update'
      @billing_frequency = BillingFrequency.find(params[:id])
    end

    # POST /billing_frequencies
    # POST /billing_frequencies.json
    def create
      @breadcrumb = 'create'
      @billing_frequency = BillingFrequency.new(params[:billing_frequency])
      @billing_frequency.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billing_frequency.save
          format.html { redirect_to @billing_frequency, notice: t('activerecord.attributes.billing_frequency.create') }
          format.json { render json: @billing_frequency, status: :created, location: @billing_frequency }
        else
          format.html { render action: "new" }
          format.json { render json: @billing_frequency.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /billing_frequencies/1
    # PUT /billing_frequencies/1.json
    def update
      @breadcrumb = 'update'
      @billing_frequency = BillingFrequency.find(params[:id])
      @billing_frequency.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billing_frequency.update_attributes(params[:billing_frequency])
          format.html { redirect_to @billing_frequency,
                        notice: (crud_notice('updated', @billing_frequency) + "#{undo_link(@billing_frequency)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billing_frequency.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /billing_frequencies/1
    # DELETE /billing_frequencies/1.json
    def destroy
      @billing_frequency = BillingFrequency.find(params[:id])

      respond_to do |format|
        if @billing_frequency.destroy
          format.html { redirect_to billing_frequencies_path, notice: (crud_notice('destroyed', @billing_frequency) + "#{undo_link(@billing_frequency)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to billing_frequencies_url, alert: "#{@billing_frequency.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @billing_frequency.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      BillingFrequency.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
