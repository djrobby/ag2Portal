require_dependency "ag2_human/application_controller"

module Ag2Human
  class InsurancesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /insurances
    # GET /insurances.json
    def index
      @insurances = Insurance.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @insurances }
      end
    end
  
    # GET /insurances/1
    # GET /insurances/1.json
    def show
      @breadcrumb = 'read'
      @insurance = Insurance.find(params[:id])
      @workers = @insurance.workers.paginate(:page => params[:page], :per_page => per_page).order('worker_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @insurance }
      end
    end
  
    # GET /insurances/new
    # GET /insurances/new.json
    def new
      @breadcrumb = 'create'
      @insurance = Insurance.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @insurance }
      end
    end
  
    # GET /insurances/1/edit
    def edit
      @breadcrumb = 'update'
      @insurance = Insurance.find(params[:id])
    end
  
    # POST /insurances
    # POST /insurances.json
    def create
      @breadcrumb = 'create'
      @insurance = Insurance.new(params[:insurance])
      @insurance.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @insurance.save
          format.html { redirect_to @insurance, notice: crud_notice('created', @insurance) }
          format.json { render json: @insurance, status: :created, location: @insurance }
        else
          format.html { render action: "new" }
          format.json { render json: @insurance.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /insurances/1
    # PUT /insurances/1.json
    def update
      @breadcrumb = 'update'
      @insurance = Insurance.find(params[:id])
      @insurance.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @insurance.update_attributes(params[:insurance])
          format.html { redirect_to @insurance,
                        notice: (crud_notice('updated', @insurance) + "#{undo_link(@insurance)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @insurance.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /insurances/1
    # DELETE /insurances/1.json
    def destroy
      @insurance = Insurance.find(params[:id])

      respond_to do |format|
        if @insurance.destroy
          format.html { redirect_to insurances_url,
                      notice: (crud_notice('destroyed', @insurance) + "#{undo_link(@insurance)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to insurances_url, alert: "#{@insurance.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @insurance.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Insurance.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
