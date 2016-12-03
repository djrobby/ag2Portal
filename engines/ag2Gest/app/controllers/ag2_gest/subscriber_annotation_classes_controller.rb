require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class SubscriberAnnotationClassesController < ApplicationController
    # GET /subscriber_annotation_classes
    # GET /subscriber_annotation_classes.json
    def index
      @subscriber_annotation_classes = SubscriberAnnotationClass.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @subscriber_annotation_classes }
      end
    end
  
    # GET /subscriber_annotation_classes/1
    # GET /subscriber_annotation_classes/1.json
    def show
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @subscriber_annotation_class }
      end
    end
  
    # GET /subscriber_annotation_classes/new
    # GET /subscriber_annotation_classes/new.json
    def new
      @subscriber_annotation_class = SubscriberAnnotationClass.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @subscriber_annotation_class }
      end
    end
  
    # GET /subscriber_annotation_classes/1/edit
    def edit
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])
    end
  
    # POST /subscriber_annotation_classes
    # POST /subscriber_annotation_classes.json
    def create
      @subscriber_annotation_class = SubscriberAnnotationClass.new(params[:subscriber_annotation_class])
  
      respond_to do |format|
        if @subscriber_annotation_class.save
          format.html { redirect_to @subscriber_annotation_class, notice: 'Subscriber annotation class was successfully created.' }
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
      @subscriber_annotation_class = SubscriberAnnotationClass.find(params[:id])
  
      respond_to do |format|
        if @subscriber_annotation_class.update_attributes(params[:subscriber_annotation_class])
          format.html { redirect_to @subscriber_annotation_class, notice: 'Subscriber annotation class was successfully updated.' }
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
      @subscriber_annotation_class.destroy
  
      respond_to do |format|
        format.html { redirect_to subscriber_annotation_classes_url }
        format.json { head :no_content }
      end
    end
  end
end
