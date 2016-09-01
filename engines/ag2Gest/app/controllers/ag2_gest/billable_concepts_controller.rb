require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class BillableConceptsController < ApplicationController
    # GET /billable_concepts
    # GET /billable_concepts.json
    def index
      @billable_concepts = BillableConcept.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @billable_concepts }
      end
    end
  
    # GET /billable_concepts/1
    # GET /billable_concepts/1.json
    def show
      @billable_concept = BillableConcept.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @billable_concept }
      end
    end
  
    # GET /billable_concepts/new
    # GET /billable_concepts/new.json
    def new
      @billable_concept = BillableConcept.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @billable_concept }
      end
    end
  
    # GET /billable_concepts/1/edit
    def edit
      @billable_concept = BillableConcept.find(params[:id])
    end
  
    # POST /billable_concepts
    # POST /billable_concepts.json
    def create
      @billable_concept = BillableConcept.new(params[:billable_concept])
  
      respond_to do |format|
        if @billable_concept.save
          format.html { redirect_to @billable_concept, notice: 'Billable concept was successfully created.' }
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
      @billable_concept = BillableConcept.find(params[:id])
  
      respond_to do |format|
        if @billable_concept.update_attributes(params[:billable_concept])
          format.html { redirect_to @billable_concept, notice: 'Billable concept was successfully updated.' }
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
      @billable_concept.destroy
  
      respond_to do |format|
        format.html { redirect_to billable_concepts_url }
        format.json { head :no_content }
      end
    end
  end
end
