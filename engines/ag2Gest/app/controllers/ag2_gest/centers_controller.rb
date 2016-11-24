require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CentersController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /centers
    # GET /centers.json
    def index

      manage_filter_state
      @centers = Center.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @centers }
        format.js
      end
    end

    # GET /centers/1
    # GET /centers/1.json
    def show
      @breadcrumb = 'read'
      @center = Center.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @center }
      end
    end

    # GET /centers/new
    # GET /centers/new.json
    def new
      @breadcrumb = 'create'
      @center = Center.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @center }
      end
    end

    # GET /centers/1/edit
    def edit
      @breadcrumb = 'update'
      @center = Center.find(params[:id])
    end

    # POST /centers
    # POST /centers.json
    def create
      @breadcrumb = 'create'
      @center = Center.new(params[:center])
      @center.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @center.save
          format.html { redirect_to @center, notice: t('activerecord.attributes.center.create') }
          format.json { render json: @center, status: :created, location: @center }
        else
          format.html { render action: "new" }
          format.json { render json: @center.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /centers/1
    # PUT /centers/1.json
    def update
      @breadcrumb = 'update'
      @center = Center.find(params[:id])
      @center.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @center.update_attributes(params[:center])
          format.html { redirect_to @center,
                        notice: (crud_notice('updated', @center) + "#{undo_link(@center)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @center.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /centers/1
    # DELETE /centers/1.json
    def destroy
      @center = Center.find(params[:id])

      respond_to do |format|
        if @center.destroy
          format.html { redirect_to centers_url,
                      notice: (crud_notice('destroyed', @center) + "#{undo_link(@center)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to centers_url, alert: "#{@center.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @center.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Center.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
