require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class BudgetsController < ApplicationController
    # GET /budgets
    # GET /budgets.json
    def index
      @budgets = Budget.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @budgets }
      end
    end
  
    # GET /budgets/1
    # GET /budgets/1.json
    def show
      @breadcrumb = 'read'
      @budget = Budget.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @budget }
      end
    end
  
    # GET /budgets/new
    # GET /budgets/new.json
    def new
      @breadcrumb = 'create'
      @budget = Budget.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @budget }
      end
    end
  
    # GET /budgets/1/edit
    def edit
      @breadcrumb = 'update'
      @budget = Budget.find(params[:id])
    end
  
    # POST /budgets
    # POST /budgets.json
    def create
      @breadcrumb = 'create'
      @budget = Budget.new(params[:budget])
      @budget.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget.save
          format.html { redirect_to @budget, notice: crud_notice('created', @budget) }
          format.json { render json: @budget, status: :created, location: @budget }
        else
          format.html { render action: "new" }
          format.json { render json: @budget.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /budgets/1
    # PUT /budgets/1.json
    def update
      @breadcrumb = 'update'
      @budget = Budget.find(params[:id])
      @budget.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @budget.update_attributes(params[:budget])
          format.html { redirect_to @budget,
                        notice: (crud_notice('updated', @budget) + "#{undo_link(@budget)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @budget.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /budgets/1
    # DELETE /budgets/1.json
    def destroy
      @budget = Budget.find(params[:id])

      respond_to do |format|
        if @budget.destroy
          format.html { redirect_to budgets_url,
                      notice: (crud_notice('destroyed', @budget) + "#{undo_link(@budget)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to budgets_url, alert: "#{@budget.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @budget.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
