require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class RegulationsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /regulations
    def index

      manage_filter_state

      @regulations = Regulation.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @regulations }
        format.js
      end

    end

    # GET /regulations/1
    def show
      @breadcrumb = 'read'
      @regulation = Regulation.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @regulation }
      end
    end

    # GET /regulations/new
    def new
      get_projects
      @breadcrumb = 'create'
      @regulation = Regulation.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @regulation }
      end
    end

    # GET /regulations/1/edit
    def edit
      get_projects
      @breadcrumb = 'update'
      @regulation = Regulation.find(params[:id])
    end

    # POST /regulations
    def create
      get_projects
      @breadcrumb = 'create'
      @regulation = Regulation.new(params[:regulation])
      @regulation.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @regulation.save
          format.html { redirect_to @regulation, notice: t('activerecord.attributes.regulation.create') }
          format.json { render json: @regulation, status: :created, location: @regulation }
        else
          format.html { render action: "new" }
          format.json { render json: @regulation.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /regulations/1
    def update
      get_projects
      @breadcrumb = 'update'
      @regulation = Regulation.find(params[:id])
      @regulation.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @regulation.update_attributes(params[:regulation])
          format.html { redirect_to @regulation,
                        notice: (crud_notice('updated', @regulation) + "#{undo_link(@regulation)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @regulation.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /regulations/1
    def destroy
      @regulation = Regulation.find(params[:id])

      respond_to do |format|
        if @regulation.destroy
          format.html { redirect_to regulations_url,
                      notice: (crud_notice('destroyed', @regulation) + "#{undo_link(@regulation)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to regulations_url, alert: "#{@regulation.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @regulation.errors, status: :unprocessable_entity }
        end
      end
    end

    private

      def get_projects
        if session[:office] != '0'
          @projects = Office.find(session[:office]).projects.order('name') #Array de projects
        elsif session[:organization] != '0'
          @projects = Organization.find(session[:organization]).projects.order('name') #Array de projects
        elsif session[:company] != '0'
          @projects = Company.find(session[:company]).projects.order('name') #Array de projects
        else
          @projects = Project.all
        end
      end

      # Use callbacks to share common setup or constraints between actions.
      def sort_column
        Regulation.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
