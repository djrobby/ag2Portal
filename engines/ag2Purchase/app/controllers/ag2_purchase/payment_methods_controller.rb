require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class PaymentMethodsController < ApplicationController
    # GET /payment_methods
    # GET /payment_methods.json
    def index
      @payment_methods = PaymentMethod.paginate(:page => params[:page], :per_page => per_page).order('description')
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @payment_methods }
      end
    end
  
    # GET /payment_methods/1
    # GET /payment_methods/1.json
    def show
      @breadcrumb = 'read'
      @payment_method = PaymentMethod.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @payment_method }
      end
    end
  
    # GET /payment_methods/new
    # GET /payment_methods/new.json
    def new
      @breadcrumb = 'create'
      @payment_method = PaymentMethod.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @payment_method }
      end
    end
  
    # GET /payment_methods/1/edit
    def edit
      @breadcrumb = 'update'
      @payment_method = PaymentMethod.find(params[:id])
    end
  
    # POST /payment_methods
    # POST /payment_methods.json
    def create
      @breadcrumb = 'create'
      @payment_method = PaymentMethod.new(params[:payment_method])
      @payment_method.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @payment_method.save
          format.html { redirect_to @payment_method, notice: crud_notice('created', @payment_method) }
          format.json { render json: @payment_method, status: :created, location: @payment_method }
        else
          format.html { render action: "new" }
          format.json { render json: @payment_method.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /payment_methods/1
    # PUT /payment_methods/1.json
    def update
      @breadcrumb = 'update'
      @payment_method = PaymentMethod.find(params[:id])
      @payment_method.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @payment_method.update_attributes(params[:payment_method])
          format.html { redirect_to @payment_method,
                        notice: (crud_notice('updated', @payment_method) + "#{undo_link(@payment_method)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @payment_method.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /payment_methods/1
    # DELETE /payment_methods/1.json
    def destroy
      @payment_method = PaymentMethod.find(params[:id])
      @payment_method.destroy
  
      respond_to do |format|
        format.html { redirect_to payment_methods_url,
                      notice: (crud_notice('destroyed', @payment_method) + "#{undo_link(@payment_method)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
