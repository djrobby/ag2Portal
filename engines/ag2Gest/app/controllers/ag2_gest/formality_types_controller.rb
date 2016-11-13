require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class FormalityTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /formality_types
    # GET /formality_types.json
    def index
      manage_filter_state
      @formality_types = FormalityType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @formality_types }
        format.js
      end
    end

    # GET /formality_types/1
    # GET /formality_types/1.json
    def show
      @breadcrumb = 'read'
      @formality_type = FormalityType.find(params[:id])
      @formalities = @formality_type.formalities.paginate(:page => params[:page], :per_page => per_page).order(:code)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @formality_type }
      end
    end

    # GET /formality_types/new
    # GET /formality_types/new.json
    def new
      @breadcrumb = 'create'
      @formality_type = FormalityType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @formality_type }
      end
    end

    # GET /formality_types/1/edit
    def edit
      @breadcrumb = 'update'
      @formality_type = FormalityType.find(params[:id])
    end

    # POST /formality_types
    # POST /formality_types.json
    def create
      @breadcrumb = 'create'
      @formality_type = FormalityType.new(params[:formality_type])
      @formality_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @formality_type.save
          format.html { redirect_to @formality_type, notice: crud_notice('created', @formality_type) }
          format.json { render json: @formality_type, status: :created, location: @formality_type }
        else
          format.html { render action: "new" }
          format.json { render json: @formality_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /formality_types/1
    # PUT /formality_types/1.json
    def update
      @breadcrumb = 'update'
      @formality_type = FormalityType.find(params[:id])
      @formality_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @formality_type.update_attributes(params[:formality_type])
          format.html { redirect_to @formality_type,
                        notice: (crud_notice('updated', @formality_type) + "#{undo_link(@formality_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @formality_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /formality_types/1
    # DELETE /formality_types/1.json
    def destroy
      @formality_type = FormalityType.find(params[:id])

      respond_to do |format|
        if @formality_type.destroy
          format.html { redirect_to formality_types_url,
                      notice: (crud_notice('destroyed', @formality_type) + "#{undo_link(@formality_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to formality_types_url, alert: "#{@formality_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @formality_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      FormalityType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
