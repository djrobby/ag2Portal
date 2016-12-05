require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SubscriberAnnotationClassesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /subscriber_annotation_classes
    # GET /subscriber_annotation_classes.json
    def index
      manage_filter_state
      @subscriber_annotation_classes = SubscriberAnnotationClass.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @subscriber_annotation_classes }
        format.js
      end
    end

    # GET /subscriber_annotation_classes/1
    # GET /subscriber_annotation_classes/1.json
    def show
      @breadcrumb = 'read'
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])
      @annotations = @subscriber_annotation_class.subscriber_annotations.by_subscriber_class

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @subscriber_annotation_class }
      end
    end

    # GET /subscriber_annotation_classes/new
    # GET /subscriber_annotation_classes/new.json
    def new
      @breadcrumb = 'create'
      @subscriber_annotation_class = SubscriberAnnotationClass.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subscriber_annotation_class }
      end
    end

    # GET /subscriber_annotation_classes/1/edit
    def edit
      @breadcrumb = 'update'
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])
    end

    # POST /subscriber_annotation_classes
    # POST /subscriber_annotation_classes.json
    def create
      @breadcrumb = 'create'
      @subscriber_annotation_class = SubscriberAnnotationClass.new(params[:subscriber_annotation_class])
      @subscriber_annotation_class.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @subscriber_annotation_class.save
          format.html { redirect_to @subscriber_annotation_class, notice: crud_notice('created', @subscriber_annotation_class) }
          format.json { render json: @subscriber_annotation_class, status: :created, location: @subscriber_annotation_class }
        else
          format.html { render action: "new" }
          format.json { render json: @subscriber_annotation_class.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /subscriber_annotation_classes/1
    # PUT /subscriber_annotation_classes/1.json
    def update
      @breadcrumb = 'update'
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])
      @subscriber_annotation_class.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @subscriber_annotation_class.update_attributes(params[:subscriber_annotation_class])
          format.html { redirect_to @subscriber_annotation_class,
                        notice: (crud_notice('updated', @subscriber_annotation_class) + "#{undo_link(@subscriber_annotation_class)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @subscriber_annotation_class.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /subscriber_annotation_classes/1
    # DELETE /subscriber_annotation_classes/1.json
    def destroy
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])

      respond_to do |format|
        if @subscriber_annotation_class.destroy
          format.html { redirect_to subscriber_annotation_classes_url,
                      notice: (crud_notice('destroyed', @subscriber_annotation_class) + "#{undo_link(@subscriber_annotation_class)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to subscriber_annotation_classes_url, alert: "#{@subscriber_annotation_class.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @subscriber_annotation_class.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      SubscriberAnnotationClass.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
