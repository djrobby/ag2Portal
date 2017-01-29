require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterTypesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meter_types
    # GET /meter_types.json
    def index
      manage_filter_state
      @meter_types = MeterType.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_types }
        format.js
      end
    end

    # GET /meter_types/1
    # GET /meter_types/1.json
    def show

      @breadcrumb = 'read'
      @meter_type = MeterType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_type }
      end
    end

    # GET /meter_types/new
    # GET /meter_types/new.json
    def new
      @breadcrumb = 'create'
      @meter_type = MeterType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_type }
      end
    end

    # GET /meter_types/1/edit
    def edit
      @breadcrumb = 'update'
      @meter_type = MeterType.find(params[:id])
    end

    # POST /meter_types
    # POST /meter_types.json
    def create
      @breadcrumb = 'create'
      @meter_type = MeterType.new(params[:meter_type])
      @meter_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_type.save
          format.html { redirect_to @meter_type, notice: t('activerecord.attributes.meter_type.create') }
          format.json { render json: @meter_type, status: :created, location: @meter_type }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meter_types/1
    # PUT /meter_types/1.json
    def update
      @breadcrumb = 'update'
      @meter_type = MeterType.find(params[:id])
      @meter_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_type.update_attributes(params[:meter_type])
          format.html { redirect_to @meter_type,
                        notice: (crud_notice('updated', @meter_type) + "#{undo_link(@meter_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meter_types/1
    # DELETE /meter_types/1.json
    def destroy
      @meter_type = MeterType.find(params[:id])

      respond_to do |format|
        if @meter_type.destroy
          format.html { redirect_to meter_types_url,
                      notice: (crud_notice('destroyed', @meter_type) + "#{undo_link(@meter_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to meter_types_url, alert: "#{@meter_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @meter_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      MeterType.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
