require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class CalibersController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /calibers
    # GET /calibers.json
    def index

      manage_filter_state

      @calibers = Caliber.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @calibers }
        format.js
      end
    end

    # GET /calibers/1
    # GET /calibers/1.json
    def show
      @breadcrumb = 'read'
      @caliber = Caliber.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @caliber }
      end
    end

    # GET /calibers/new
    # GET /calibers/new.json
    def new
      @breadcrumb = 'create'
      @caliber = Caliber.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @caliber }
      end
    end

    # GET /calibers/1/edit
    def edit
      @breadcrumb = 'update'
      @caliber = Caliber.find(params[:id])
    end

    # POST /calibers
    # POST /calibers.json
    def create
      @breadcrumb = 'create'
      @caliber = Caliber.new(params[:caliber])
      @caliber.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @caliber.save
          format.html { redirect_to @caliber, notice: t('activerecord.attributes.caliber.create') }
          format.json { render json: @caliber, status: :created, location: @caliber }
        else
          format.html { render action: "new" }
          format.json { render json: @caliber.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /calibers/1
    # PUT /calibers/1.json
    def update
      @breadcrumb = 'update'
      @caliber = Caliber.find(params[:id])
      @caliber.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @caliber.update_attributes(params[:caliber])
          format.html { redirect_to @caliber,
                        notice: (crud_notice('updated', @caliber) + "#{undo_link(@caliber)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @caliber.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /calibers/1
    # DELETE /calibers/1.json
    def destroy
      @caliber = Caliber.find(params[:id])

      respond_to do |format|
        if @caliber.destroy
          format.html { redirect_to calibers_url,
                      notice: (crud_notice('destroyed', @caliber) + "#{undo_link(@caliber)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to calibers_url, alert: "#{@caliber.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @caliber.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Caliber.column_names.include?(params[:sort]) ? params[:sort] : "caliber"
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
