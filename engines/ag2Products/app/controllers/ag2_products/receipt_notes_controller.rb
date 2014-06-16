require_dependency "ag2_products/application_controller"

module Ag2Products
  class ReceiptNotesController < ApplicationController
    # GET /receipt_notes
    # GET /receipt_notes.json
    def index
      @receipt_notes = ReceiptNote.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @receipt_notes }
      end
    end
  
    # GET /receipt_notes/1
    # GET /receipt_notes/1.json
    def show
      @receipt_note = ReceiptNote.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/new
    # GET /receipt_notes/new.json
    def new
      @receipt_note = ReceiptNote.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/1/edit
    def edit
      @receipt_note = ReceiptNote.find(params[:id])
    end
  
    # POST /receipt_notes
    # POST /receipt_notes.json
    def create
      @receipt_note = ReceiptNote.new(params[:receipt_note])
  
      respond_to do |format|
        if @receipt_note.save
          format.html { redirect_to @receipt_note, notice: 'Receipt note was successfully created.' }
          format.json { render json: @receipt_note, status: :created, location: @receipt_note }
        else
          format.html { render action: "new" }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /receipt_notes/1
    # PUT /receipt_notes/1.json
    def update
      @receipt_note = ReceiptNote.find(params[:id])
  
      respond_to do |format|
        if @receipt_note.update_attributes(params[:receipt_note])
          format.html { redirect_to @receipt_note, notice: 'Receipt note was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /receipt_notes/1
    # DELETE /receipt_notes/1.json
    def destroy
      @receipt_note = ReceiptNote.find(params[:id])
      @receipt_note.destroy
  
      respond_to do |format|
        format.html { redirect_to receipt_notes_url }
        format.json { head :no_content }
      end
    end
  end
end
