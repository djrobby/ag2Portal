require_dependency "ag2_human/application_controller"

module Ag2Human
  class SalaryConceptsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /salary_concepts
    # GET /salary_concepts.json
    def index
      @salary_concepts = SalaryConcept.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @salary_concepts }
      end
    end
  
    # GET /salary_concepts/1
    # GET /salary_concepts/1.json
    def show
      @breadcrumb = 'read'
      @salary_concept = SalaryConcept.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @salary_concept }
      end
    end
  
    # GET /salary_concepts/new
    # GET /salary_concepts/new.json
    def new
      @breadcrumb = 'create'
      @salary_concept = SalaryConcept.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @salary_concept }
      end
    end
  
    # GET /salary_concepts/1/edit
    def edit
      @breadcrumb = 'update'
      @salary_concept = SalaryConcept.find(params[:id])
    end
  
    # POST /salary_concepts
    # POST /salary_concepts.json
    def create
      @breadcrumb = 'create'
      @salary_concept = SalaryConcept.new(params[:salary_concept])
      @salary_concept.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @salary_concept.save
          format.html { redirect_to @salary_concept, notice: crud_notice('created', @salary_concept) }
          format.json { render json: @salary_concept, status: :created, location: @salary_concept }
        else
          format.html { render action: "new" }
          format.json { render json: @salary_concept.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /salary_concepts/1
    # PUT /salary_concepts/1.json
    def update
      @breadcrumb = 'update'
      @salary_concept = SalaryConcept.find(params[:id])
      @salary_concept.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @salary_concept.update_attributes(params[:salary_concept])
          format.html { redirect_to @salary_concept,
                        notice: (crud_notice('updated', @salary_concept) + "#{undo_link(@salary_concept)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @salary_concept.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /salary_concepts/1
    # DELETE /salary_concepts/1.json
    def destroy
      @salary_concept = SalaryConcept.find(params[:id])

      respond_to do |format|
        if @salary_concept.destroy
          format.html { redirect_to salary_concepts_url,
                      notice: (crud_notice('destroyed', @salary_concept) + "#{undo_link(@salary_concept)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to salary_concepts_url, alert: "#{@salary_concept.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @salary_concept.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      SalaryConcept.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  end
end
