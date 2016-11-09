require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillingIncidenceTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /billing_incidence_types
    # GET /billing_incidence_types.json
    def index
      manage_filter_state
      @billing_incidence_types = BillingIncidenceType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billing_incidence_types }
        format.js
      end
    end

    # GET /billing_incidence_types/1
    # GET /billing_incidence_types/1.json
    def show
      @billing_incidence_type = BillingIncidenceType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billing_incidence_type }
      end
    end

    # GET /billing_incidence_types/new
    # GET /billing_incidence_types/new.json
    def new
      @billing_incidence_type = BillingIncidenceType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billing_incidence_type }
      end
    end

    # GET /billing_incidence_types/1/edit
    def edit
      @billing_incidence_type = BillingIncidenceType.find(params[:id])
    end

    # POST /billing_incidence_types
    # POST /billing_incidence_types.json
    def create
      @billing_incidence_type = BillingIncidenceType.new(params[:billing_incidence_type])

      respond_to do |format|
        if @billing_incidence_type.save
          format.html { redirect_to @billing_incidence_type, notice: 'Billing incidence type was successfully created.' }
          format.json { render json: @billing_incidence_type, status: :created, location: @billing_incidence_type }
        else
          format.html { render action: "new" }
          format.json { render json: @billing_incidence_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /billing_incidence_types/1
    # PUT /billing_incidence_types/1.json
    def update
      @billing_incidence_type = BillingIncidenceType.find(params[:id])

      respond_to do |format|
        if @billing_incidence_type.update_attributes(params[:billing_incidence_type])
          format.html { redirect_to @billing_incidence_type, notice: 'Billing incidence type was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billing_incidence_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /billing_incidence_types/1
    # DELETE /billing_incidence_types/1.json
    def destroy
      @billing_incidence_type = BillingIncidenceType.find(params[:id])
      @billing_incidence_type.destroy

      respond_to do |format|
        format.html { redirect_to billing_incidence_types_url }
        format.json { head :no_content }
      end
    end
  end
end
