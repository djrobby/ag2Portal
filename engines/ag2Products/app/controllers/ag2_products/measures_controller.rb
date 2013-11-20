require_dependency "ag2_products/application_controller"

module Ag2Products
  class MeasuresController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /measures
    # GET /measures.json
    def index
      @measures = Measure.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @measures }
      end
    end
  
    # GET /measures/1
    # GET /measures/1.json
    def show
      @breadcrumb = 'read'
      @measure = Measure.find(params[:id])
      @products = @measure.products.paginate(:page => params[:page], :per_page => per_page).order('product_code')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @measure }
      end
    end
  
    # GET /measures/new
    # GET /measures/new.json
    def new
      @breadcrumb = 'create'
      @measure = Measure.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @measure }
      end
    end
  
    # GET /measures/1/edit
    def edit
      @breadcrumb = 'update'
      @measure = Measure.find(params[:id])
    end
  
    # POST /measures
    # POST /measures.json
    def create
      @breadcrumb = 'create'
      @measure = Measure.new(params[:measure])
      @measure.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @measure.save
          format.html { redirect_to @measure, notice: crud_notice('created', @measure) }
          format.json { render json: @measure, status: :created, location: @measure }
        else
          format.html { render action: "new" }
          format.json { render json: @measure.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /measures/1
    # PUT /measures/1.json
    def update
      @breadcrumb = 'update'
      @measure = Measure.find(params[:id])
      @measure.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @measure.update_attributes(params[:measure])
          format.html { redirect_to @measure,
                        notice: (crud_notice('updated', @measure) + "#{undo_link(@measure)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @measure.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /measures/1
    # DELETE /measures/1.json
    def destroy
      @measure = Measure.find(params[:id])

      respond_to do |format|
        if @measure.destroy
          format.html { redirect_to measures_url,
                      notice: (crud_notice('destroyed', @measure) + "#{undo_link(@measure)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to measures_url, alert: "#{@measure.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @measure.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Measure.column_names.include?(params[:sort]) ? params[:sort] : "description"
    end
  end
end
