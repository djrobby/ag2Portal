require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ComplaintClassesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /complaint_classes
    # GET /complaint_classes.json
    def index
      manage_filter_state
      @complaint_classes = ComplaintClass.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @complaint_classes }
        format.js
      end
    end

    # GET /complaint_classes/1
    # GET /complaint_classes/1.json
    def show
      @breadcrumb = 'read'
      @complaint_class = ComplaintClass.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @complaint_class }
      end
    end

    # GET /complaint_classes/new
    # GET /complaint_classes/new.json
    def new
      @breadcrumb = 'create'
      @complaint_class = ComplaintClass.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @complaint_class }
      end
    end

    # GET /complaint_classes/1/edit
    def edit
      @breadcrumb = 'update'
      @complaint_class = ComplaintClass.find(params[:id])
    end

    # POST /complaint_classes
    # POST /complaint_classes.json
    def create
      @breadcrumb = 'create'
      @complaint_class = ComplaintClass.new(params[:complaint_class])

      respond_to do |format|
        if @complaint_class.save
          format.html { redirect_to @complaint_class, notice: 'Complaint class was successfully created.' }
          format.json { render json: @complaint_class, status: :created, location: @complaint_class }
        else
          format.html { render action: "new" }
          format.json { render json: @complaint_class.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /complaint_classes/1
    # PUT /complaint_classes/1.json
    def update
      @breadcrumb = 'update'
      @complaint_class = ComplaintClass.find(params[:id])

      respond_to do |format|
        if @complaint_class.update_attributes(params[:complaint_class])
          format.html { redirect_to @complaint_class, notice: 'Complaint class was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @complaint_class.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /complaint_classes/1
    # DELETE /complaint_classes/1.json
    def destroy
      @complaint_class = ComplaintClass.find(params[:id])

      respond_to do |format|
        if @complaint_class.destroy
          format.html { redirect_to complaint_classes_url,
                      notice: (crud_notice('destroyed', @complaint_class) + "#{undo_link(@complaint_class)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to complaint_classes_url, alert: "#{@complaint_class.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @complaint_class.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ComplaintClass.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
