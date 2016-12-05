require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class UsesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /uses
    # GET /uses.json
    def index
      manage_filter_state
      @uses = Use.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @uses }
        format.js
      end
    end

    # GET /uses/1
    # GET /uses/1.json
    def show
      @breadcrumb = 'read'
      @use = Use.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @use }
      end
    end

    # GET /uses/new
    # GET /uses/new.json
    def new
      @breadcrumb = 'create'
      @use = Use.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @use }
      end
    end

    # GET /uses/1/edit
    def edit
      @breadcrumb = 'update'
      @use = Use.find(params[:id])
    end

    # POST /uses
    # POST /uses.json
    def create
      @breadcrumb = 'create'
      @use = Use.new(params[:use])
      @use.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @use.save
          format.html { redirect_to @use, notice: crud_notice('created', @use) }
          format.json { render json: @use, status: :created, location: @use }
        else
          format.html { render action: "new" }
          format.json { render json: @use.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /uses/1
    # PUT /uses/1.json
    def update
      @breadcrumb = 'update'
      @use = Use.find(params[:id])
      @use.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @use.update_attributes(params[:use])
          format.html { redirect_to @use,
                        notice: (crud_notice('updated', @use) + "#{undo_link(@use)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @use.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /uses/1
    # DELETE /uses/1.json
    def destroy
      @use = Use.find(params[:id])

      respond_to do |format|
        if @use.destroy
          format.html { redirect_to uses_url,
                      notice: (crud_notice('destroyed', @use) + "#{undo_link(@use)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to uses_url, alert: "#{@use.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @use.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Use.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
