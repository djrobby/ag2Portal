require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillableConceptsController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource

    helper_method :sort_column

    # GET /billable_concepts
    # GET /billable_concepts.json
    def index
      manage_filter_state

      @billable_concepts = BillableConcept.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)
      #BillableConcept.joins(:billable_document).order('billable_documents.name')

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billable_concepts }
        format.js
      end
    end

    # GET /billable_concepts/1
    # GET /billable_concepts/1.json
    def show
      @breadcrumb = 'read'
      @billable_concept = BillableConcept.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billable_concept }
      end
    end

    # GET /billable_concepts/new
    # GET /billable_concepts/new.json
    def new
      @breadcrumb = 'create'
      @billable_concept = BillableConcept.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billable_concept }
      end
    end

    # GET /billable_concepts/1/edit
    def edit
      @breadcrumb = 'update'
      @billable_concept = BillableConcept.find(params[:id])
    end

    # POST /billable_concepts
    # POST /billable_concepts.json
    def create
      @breadcrumb = 'create'
      @billable_concept = BillableConcept.new(params[:billable_concept])
      @billable_concept.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billable_concept.save
          format.html { redirect_to @billable_concept, notice: t('activerecord.attributes.billable_concept.create') }
          format.json { render json: @billable_concept, status: :created, location: @billable_concept }
        else
          format.html { render action: "new" }
          format.json { render json: @billable_concept.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /billable_concepts/1
    # PUT /billable_concepts/1.json
    def update
      @breadcrumb = 'update'
      @billable_concept = BillableConcept.find(params[:id])
      @billable_concept.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @billable_concept.update_attributes(params[:billable_concept])
          format.html { redirect_to @billable_concept,
                        notice: (crud_notice('updated', @billable_concept) + "#{undo_link(@billable_concept)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @billable_concept.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /billable_concepts/1
    # DELETE /billable_concepts/1.json
    def destroy
      @billable_concept = BillableConcept.find(params[:id])

      respond_to do |format|
        if @billable_concept.destroy
          format.html { redirect_to billable_concepts_url,
                      notice: (crud_notice('destroyed', @billable_concept) + "#{undo_link(@billable_concept)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to billable_concepts_url, alert: "#{@billable_concept.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @billable_concept.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      BillableConcept.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
