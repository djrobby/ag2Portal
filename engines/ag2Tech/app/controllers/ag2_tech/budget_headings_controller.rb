require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetHeadingsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /budget_headings
    # GET /budget_headings.json
    def index
      @budget_headings = BudgetHeading.all
      manage_filter_state
      init_oco if !session[:organization]
      if session[:organization] != '0'
        @budget_headings = BudgetHeading.where(organization_id: session[:organization].to_i).order(sort_column + ' ' + sort_direction)
      else
        @budget_headings = BudgetHeading.order(sort_column + ' ' + sort_direction)
      end
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @budget_headings }
      end
    end
  
    # GET /budget_headings/1
    # GET /budget_headings/1.json
    def show
      @breadcrumb = 'read'
      @budget_heading = BudgetHeading.find(params[:id])
      @charge_groups = @budget_heading.charge_groups.paginate(:page => params[:page], :per_page => per_page).order(:group_code)
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @budget_heading }
      end
    end
  
    # GET /budget_headings/new
    # GET /budget_headings/new.json
    def new
      @breadcrumb = 'create'
      @budget_heading = BudgetHeading.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget_heading }
      end
    end
  
    # GET /budget_headings/1/edit
    def edit
      @breadcrumb = 'update'
      @budget_heading = BudgetHeading.find(params[:id])
    end
  
    # POST /budget_headings
    # POST /budget_headings.json
    def create
      @breadcrumb = 'create'
      @budget_heading = BudgetHeading.new(params[:budget_heading])
      @charge_group.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget_heading.save
          format.html { redirect_to @budget_heading, notice: crud_notice('created', @budget_heading) }
          format.json { render json: @budget_heading, status: :created, location: @budget_heading }
        else
          format.html { render action: "new" }
          format.json { render json: @budget_heading.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /budget_headings/1
    # PUT /budget_headings/1.json
    def update
      @breadcrumb = 'update'
      @budget_heading = BudgetHeading.find(params[:id])
      @charge_group.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget_heading.update_attributes(params[:budget_heading])
          format.html { redirect_to @budget_heading,
                        notice: (crud_notice('updated', @budget_heading) + "#{undo_link(@budget_heading)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @budget_heading.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /budget_headings/1
    # DELETE /budget_headings/1.json
    def destroy
      @budget_heading = BudgetHeading.find(params[:id])
      respond_to do |format|
        if @budget_heading.destroy
          format.html { redirect_to budget_headings_url,
                      notice: (crud_notice('destroyed', @budget_heading) + "#{undo_link(@budget_heading)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to budget_headings_url, alert: "#{@budget_heading.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @budget_heading.errors, status: :unprocessable_entity }
        end
      end
    end

    private
    
    def sort_column
      BudgetHeading.column_names.include?(params[:sort]) ? params[:sort] : "heading_code"
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
