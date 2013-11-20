require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class TaxTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    
    # Update expiration and create new (expire_btn)
    def expire
      expire_type = @tax_type
      new_type = TaxType.new
      
      # Create new tax type based on current
      new_type.description = expire_type.description
      new_type.tax = expire_type.tax
      new_type.created_by = current_user.id if !current_user.nil?
      if new_type.save
        code = new_type.id.to_s
      else
        code = '$err'
      end
      @json_data = { "code" => code }

      # Update linked tables with the new tax type created
      
      respond_to do |format|
        format.html # expire.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /tax_types
    # GET /tax_types.json
    def index
      filter = params[:filter]
      if filter == "all"
        @tax_types = TaxType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif filter == "current"
        @tax_types = TaxType.where("expiration IS NULL").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      elsif filter == "expired"
        @tax_types = TaxType.where("NOT expiration IS NULL").paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      else
        @tax_types = TaxType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
      end
  
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
