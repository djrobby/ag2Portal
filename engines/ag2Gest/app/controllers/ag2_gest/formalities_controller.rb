require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class FormalitiesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /formalities
    # GET /formalities.json
    def index
      manage_filter_state
      @formalities = Formality.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @formalities }
        format.js
      end
    end

    # GET /formalities/1
    # GET /formalities/1.json
    def show
      @breadcrumb = 'read'
      @formality = Formality.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @formality }
      end
    end

    # GET /formalities/new
    # GET /formalities/new.json
    def new
      @breadcrumb = 'create'
      @formality = Formality.new
      @formality_types = FormalityType.all

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @formality }
      end
    end

    # GET /formalities/1/edit
    def edit
      @breadcrumb = 'update'
      @formality = Formality.find(params[:id])
      @formality_types = FormalityType.all
    end

    # POST /formalities
    # POST /formalities.json
    def create
      @breadcrumb = 'create'
      @formality = Formality.new(params[:formality])
      @formality.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @formality.save
          format.html { redirect_to @formality, notice: crud_notice('created', @formality) }
          format.json { render json: @formality, status: :created, location: @formality }
        else
          @formality_types = FormalityType.all
          format.html { render action: "new" }
          format.json { render json: @formality.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /formalities/1
    # PUT /formalities/1.json
    def update
      @breadcrumb = 'update'
      @formality = Formality.find(params[:id])
      @formality.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @formality.update_attributes(params[:formality])
          format.html { redirect_to @formality,
                        notice: (crud_notice('updated', @formality) + "#{undo_link(@formality)}").html_safe }
          format.json { head :no_content }
        else
          @formality_types = FormalityType.all
          format.html { render action: "edit" }
          format.json { render json: @formality.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /formalities/1
    # DELETE /formalities/1.json
    def destroy
      @formality = Formality.find(params[:id])

      respond_to do |format|
        if @formality.destroy
          format.html { redirect_to formalities_url,
                      notice: (crud_notice('destroyed', @formality) + "#{undo_link(@formality)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to formalities_url, alert: "#{@formality.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @formality.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Formality.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
