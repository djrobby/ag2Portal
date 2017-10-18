require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ZipcodesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => :update_province_textfield_from_town
    # Helper methods for sorting
    helper_method :sort_column
    # Update hidden province text field at view from town select
    def update_province_textfield_from_town
      @town = Town.find(params[:id])
      @province = @town.province
      #@province = Province.find(@town.province)

      respond_to do |format|
        format.html # update_province_textfield.html.erb does not exist! JSON only
        format.json { render json: @province }
      end
    end

    # GET /zipcodes
    # GET /zipcodes.json
    def index
      manage_filter_state

      @search = Zipcode.search do
        fulltext params[:search]
        data_accessor_for(Zipcode).include = [:town, :province]
        order_by sort_column, sort_direction
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @zipcodes = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @zipcodes }
        format.js
      end

      # manage_filter_state
      # @zipcodes = Zipcode.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      # respond_to do |format|
      #   format.html # index.html.erb
      #   format.json { render json: @zipcodes }
      #   format.js
      # end
    end

    # GET /zipcodes/1
    # GET /zipcodes/1.json
    def show
      @breadcrumb = 'read'
      @zipcode = Zipcode.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @zipcode }
      end
    end

    # GET /zipcodes/new
    # GET /zipcodes/new.json
    def new
      @breadcrumb = 'create'
      @zipcode = Zipcode.new
      @towns = towns_dropdown
      @provinces = provinces_dropdown

      # @towns = Town.connection.select_all('select * from towns order by name')
      # @towns = Town.find_by_sql('SELECT * FROM TOWNS ORDER BY NAME')

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @zipcode }
      end
    end

    # GET /zipcodes/1/edit
    def edit
      @breadcrumb = 'update'
      @zipcode = Zipcode.find(params[:id])
      @towns = towns_dropdown
      @provinces = provinces_dropdown
    end

    # POST /zipcodes
    # POST /zipcodes.json
    def create
      @breadcrumb = 'create'
      @zipcode = Zipcode.new(params[:zipcode])
      @zipcode.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @zipcode.save
          format.html { redirect_to @zipcode, notice: crud_notice('created', @zipcode) }
          format.json { render json: @zipcode, status: :created, location: @zipcode }
        else
          @towns = towns_dropdown
          @provinces = provinces_dropdown
          format.html { render action: "new" }
          format.json { render json: @zipcode.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /zipcodes/1
    # PUT /zipcodes/1.json
    def update
      @breadcrumb = 'update'
      @zipcode = Zipcode.find(params[:id])
      @zipcode.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @zipcode.update_attributes(params[:zipcode])
          format.html { redirect_to @zipcode,
                        notice: (crud_notice('updated', @zipcode) + "#{undo_link(@zipcode)}").html_safe }
          format.json { head :no_content }
        else
          @towns = towns_dropdown
          @provinces = provinces_dropdown
          format.html { render action: "edit" }
          format.json { render json: @zipcode.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /zipcodes/1
    # DELETE /zipcodes/1.json
    def destroy
      @zipcode = Zipcode.find(params[:id])

      respond_to do |format|
        if @zipcode.destroy
          format.html { redirect_to zipcodes_url,
                      notice: (crud_notice('destroyed', @zipcode) + "#{undo_link(@zipcode)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to zipcodes_url, alert: "#{@zipcode.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @zipcode.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def towns_dropdown
      Town.order(:name).includes(:province)
    end

    def provinces_dropdown
      Province.order(:name).includes(:region)
    end

    def sort_column
      Zipcode.column_names.include?(params[:sort]) ? params[:sort] : "zipcode"
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
