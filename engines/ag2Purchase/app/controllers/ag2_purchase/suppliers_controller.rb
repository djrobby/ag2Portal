require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class SuppliersController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:update_province_textfield_from_town,
                                               :update_province_textfield_from_zipcode,
                                               :update_code_textfield_from_name]

    # Update province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield_from_town.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # Update province and town text fields at view from zip code select
    def update_province_textfield_from_zipcode
      @zipcode = Zipcode.find(params[:id])
      @town = Town.find(@zipcode.town)
      @province = Province.find(@town.province)
      @json_data = { "town_id" => @town.id, "province_id" => @province.id }

      respond_to do |format|
        format.html # update_province_textfield_from_zipcode.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    # Update worker code at view from last_name and first_name (generate_code_btn)
    def update_code_textfield_from_name
      fullname = params[:id]
      lastname = fullname.split("$").first
      firstname = fullname.split("$").last
      lastname1 = lastname.split(" ").first
      lastname2 = lastname.split(" ").last
      code = ''

      # Builds code, if possible
      if !lastname1.nil? && lastname1.length > 1
      code += lastname1[0, 2]
      end
      if !lastname2.nil? && lastname2.length > 1
      code += lastname2[0, 2]
      end
      if !firstname.nil? && firstname.length > 0
      code += firstname[0, 1]
      end

      if code == ''
        code = 'LLNNF'
      else
        if code.length < 5
          code = code.ljust(5, '0')
        end
      end

      code.upcase!
      if code == 'LLNNF'
        code = '$err'
      end
      @json_data = { "code" => code }

      respond_to do |format|
        format.html # update_code_textfield_from_name.html.erb does not exist! JSON only
        format.json { render json: @json_data }
      end
    end

    #
    # Default Methods
    #
    # GET /suppliers
    # GET /suppliers.json
    def index
      #@suppliers = Supplier.all
      @search = Supplier.search do
        fulltext params[:search]
        order_by :supplier_code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      if letter.blank? || letter == "%"
        @suppliers = @search.results
      else
        @suppliers = Supplier.where("name LIKE ?", "#{letter}%").paginate(:page => params[:page], :per_page => per_page).order('supplier_code')
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @suppliers }
      end
    end
  
    # GET /suppliers/1
    # GET /suppliers/1.json
    def show
      @breadcrumb = 'read'
      @supplier = Supplier.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @supplier }
      end
    end
  
    # GET /suppliers/new
    # GET /suppliers/new.json
    def new
      @breadcrumb = 'create'
      @supplier = Supplier.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @supplier }
      end
    end
  
    # GET /suppliers/1/edit
    def edit
      @breadcrumb = 'update'
      @supplier = Supplier.find(params[:id])
    end
  
    # POST /suppliers
    # POST /suppliers.json
    def create
      @breadcrumb = 'create'
      @supplier = Supplier.new(params[:supplier])
      @supplier.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @supplier.save
          format.html { redirect_to @supplier, notice: crud_notice('created', @supplier) }
          format.json { render json: @supplier, status: :created, location: @supplier }
        else
          format.html { render action: "new" }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /suppliers/1
    # PUT /suppliers/1.json
    def update
      @breadcrumb = 'update'
      @supplier = Supplier.find(params[:id])
      @supplier.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @supplier.update_attributes(params[:supplier])
          format.html { redirect_to @supplier,
                        notice: (crud_notice('updated', @supplier) + "#{undo_link(@supplier)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @supplier.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /suppliers/1
    # DELETE /suppliers/1.json
    def destroy
      @supplier = Supplier.find(params[:id])
      @supplier.destroy
  
      respond_to do |format|
        format.html { redirect_to suppliers_url,
                      notice: (crud_notice('destroyed', @supplier) + "#{undo_link(@supplier)}").html_safe }
        format.json { head :no_content }
      end
    end
  end
end
