require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterModelsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meter_models
    # GET /meter_models.json
    def index
      manage_filter_state
      @meter_models = MeterModel.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_models }
        format.js
      end
    end

    # GET /meter_models/1
    # GET /meter_models/1.json
    def show

      @breadcrumb = 'read'
      @meter_model = MeterModel.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_model }
      end
    end

    # GET /meter_models/new
    # GET /meter_models/new.json
    def new
      @breadcrumb = 'create'
      @meter_model = MeterModel.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_model }
      end
    end

    # GET /meter_models/1/edit
    def edit
      @breadcrumb = 'update'
      @meter_model = MeterModel.find(params[:id])
    end

    # POST /meter_models
    # POST /meter_models.json
    def create
      @breadcrumb = 'create'
      @meter_model = MeterModel.new(params[:meter_model])
      @meter_model.created_by = current_user.id if !current_user.nil?
      respond_to do |format|
        if @meter_model.save
          format.html { redirect_to @meter_model, notice: t('activerecord.attributes.meter_model.create') }
          format.json { render json: @meter_model, status: :created, location: @meter_model }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_model.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meter_models/1
    # PUT /meter_models/1.json
    def update
      @breadcrumb = 'update'
      @meter_model = MeterModel.find(params[:id])
      @meter_model.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_model.update_attributes(params[:meter_model])
          format.html { redirect_to @meter_model,
                        notice: (crud_notice('updated', @meter_model) + "#{undo_link(@meter_model)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_model.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meter_models/1
    # DELETE /meter_models/1.json
    def destroy
      @meter_model = MeterModel.find(params[:id])

      respond_to do |format|
        if @meter_model.destroy
          format.html { redirect_to meter_models_url,
                      notice: (crud_notice('destroyed', @meter_model) + "#{undo_link(@meter_model)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to meter_models_url, alert: "#{@meter_model.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @meter_model.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      MeterModel.column_names.include?(params[:sort]) ? params[:sort] : "model"
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
