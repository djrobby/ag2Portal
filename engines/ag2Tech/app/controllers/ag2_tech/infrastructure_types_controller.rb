require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class InfrastructureTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /infrastructure_types
    # GET /infrastructure_types.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @infrastructure_types = InfrastructureType.where(organization_id: session[:organization]).paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @infrastructure_types = InfrastructureType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @InfrastructureType }
        format.js
      end
    end

    # GET /infrastructure_types/1
    # GET /infrastructure_types/1.json
    def show
      @breadcrumb = 'read'
      @infrastructure_type = InfrastructureType.find(params[:id])
      @infrastructures = @infrastructure_type.infrastructures.paginate(:page => params[:page], :per_page => per_page).order(:code)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @infrastructure_type }
      end
    end

    # GET /infrastructure_types/new
    # GET /infrastructure_types/new.json
    def new
      @breadcrumb = 'create'
      @infrastructure_type = InfrastructureType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @infrastructure_type }
      end
    end

    # GET /infrastructure_types/1/edit
    def edit
      @breadcrumb = 'update'
      @infrastructure_type = InfrastructureType.find(params[:id])
    end

    # POST /infrastructure_types
    # POST /infrastructure_types.json
    def create
      @breadcrumb = 'create'
      @infrastructure_type = InfrastructureType.new(params[:infrastructure_type])
      @infrastructure_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @infrastructure_type.save
          format.html { redirect_to @infrastructure_type, notice: crud_notice('created', @infrastructure_type) }
          format.json { render json: @infrastructure_type, status: :created, location: @infrastructure_type }
        else
          format.html { render action: "new" }
          format.json { render json: @infrastructure_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /infrastructure_types/1
    # PUT /infrastructure_types/1.json
    def update
      @breadcrumb = 'update'
      @infrastructure_type = InfrastructureType.find(params[:id])
      @infrastructure_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @infrastructure_type.update_attributes(params[:infrastructure_type])
          format.html { redirect_to @infrastructure_type,
                        notice: (crud_notice('updated', @infrastructure_type) + "#{undo_link(@infrastructure_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @infrastructure_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /infrastructure_types/1
    # DELETE /infrastructure_types/1.json
    def destroy
      @infrastructure_type = InfrastructureType.find(params[:id])

      respond_to do |format|
        if @infrastructure_type.destroy
          format.html { redirect_to infrastructure_types_url,
                      notice: (crud_notice('destroyed', @infrastructure_type) + "#{undo_link(@infrastructure_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to infrastructure_types_url, alert: "#{@infrastructure_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @infrastructure_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      InfrastructureType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
