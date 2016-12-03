require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class RegulationTypesController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /regulations
    def index

      manage_filter_state

      @regulation_types = RegulationType.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @regulation_types }
        format.js
      end
    end

    # GET /regulations/1
    def show
      @breadcrumb = 'read'
      @regulation_type = RegulationType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @regulation_type }
      end
    end

    # GET /regulations/new
    def new

      @breadcrumb = 'create'
      @regulation_type = RegulationType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @regulation_type }
      end
    end

    # GET /regulations/1/edit
    def edit
      @breadcrumb = 'update'
      @regulation_type = RegulationType.find(params[:id])
    end

    # POST /regulations
    def create
      @breadcrumb = 'create'
      @regulation_type = RegulationType.new(params[:regulation_type])
      @regulation_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @regulation_type.save
          format.html { redirect_to @regulation_type, notice: t('activerecord.attributes.regulation_type.create') }
          format.json { render json: @regulation_type, status: :created, location: @regulation_type }
        else
          format.html { render action: "new" }
          format.json { render json: @regulation_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /regulations/1
    def update
      @breadcrumb = 'update'
      @regulation_type = RegulationType.find(params[:id])
      @regulation_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @regulation_type.update_attributes(params[:regulation_type])
          format.html { redirect_to @regulation_type,
                        notice: (crud_notice('updated', @regulation_type) + "#{undo_link(@regulation_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @regulation_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /regulations/1
    def destroy
      @regulation_type = RegulationType.find(params[:id])

      respond_to do |format|
        if @regulation_type.destroy
          format.html { redirect_to regulation_types_url,
                      notice: (crud_notice('destroyed', @regulation_type) + "#{undo_link(@regulation_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to regulation_types_url, alert: "#{@regulation_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @regulation_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

      # Use callbacks to share common setup or constraints between actions.
      def sort_column
        RegulationType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
