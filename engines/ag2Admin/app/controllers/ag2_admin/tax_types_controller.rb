require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class TaxTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /tax_types
    # GET /tax_types.json
    def index
      @tax_types = TaxType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tax_types }
      end
    end
  
    # GET /tax_types/1
    # GET /tax_types/1.json
    def show
      @breadcrumb = 'read'
      @tax_type = TaxType.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @tax_type }
      end
    end
  
    # GET /tax_types/new
    # GET /tax_types/new.json
    def new
      @breadcrumb = 'create'
      @tax_type = TaxType.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @tax_type }
      end
    end
  
    # GET /tax_types/1/edit
    def edit
      @breadcrumb = 'update'
      @tax_type = TaxType.find(params[:id])
    end
  
    # POST /tax_types
    # POST /tax_types.json
    def create
      @breadcrumb = 'create'
      @tax_type = TaxType.new(params[:tax_type])
      @tax_type.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @tax_type.save
          format.html { redirect_to @tax_type, notice: crud_notice('created', @tax_type) }
          format.json { render json: @tax_type, status: :created, location: @tax_type }
        else
          format.html { render action: "new" }
          format.json { render json: @tax_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /tax_types/1
    # PUT /tax_types/1.json
    def update
      @breadcrumb = 'update'
      @tax_type = TaxType.find(params[:id])
      @tax_type.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @tax_type.update_attributes(params[:tax_type])
          format.html { redirect_to @tax_type,
                        notice: (crud_notice('updated', @tax_type) + "#{undo_link(@tax_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @tax_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /tax_types/1
    # DELETE /tax_types/1.json
    def destroy
      @tax_type = TaxType.find(params[:id])
      @tax_type.destroy
  
      respond_to do |format|
        format.html { redirect_to tax_types_url,
                      notice: (crud_notice('destroyed', @tax_type) + "#{undo_link(@tax_type)}").html_safe }
        format.json { head :no_content }
      end
    end

    private

    def sort_column
      TaxType.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end
  end
end