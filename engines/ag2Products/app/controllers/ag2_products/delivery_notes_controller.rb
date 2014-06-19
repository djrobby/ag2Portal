require_dependency "ag2_products/application_controller"

module Ag2Products
  class DeliveryNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    # GET /delivery_notes
    # GET /delivery_notes.json
    def index
      @delivery_notes = DeliveryNote.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @delivery_notes }
      end
    end
  
    # GET /delivery_notes/1
    # GET /delivery_notes/1.json
    def show
      @breadcrumb = 'read'
      @delivery_note = DeliveryNote.find(params[:id])
      @items = @delivery_note.delivery_note_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @delivery_note }
      end
    end
  
    # GET /delivery_notes/new
    # GET /delivery_notes/new.json
    def new
      @breadcrumb = 'create'
      @delivery_note = DeliveryNote.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @delivery_note }
      end
    end
  
    # GET /delivery_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @delivery_note = DeliveryNote.find(params[:id])
    end
  
    # POST /delivery_notes
    # POST /delivery_notes.json
    def create
      @breadcrumb = 'create'
      @delivery_note = DeliveryNote.new(params[:delivery_note])
      @delivery_note.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @delivery_note.save
          format.html { redirect_to @delivery_note, notice: crud_notice('created', @delivery_note) }
          format.json { render json: @delivery_note, status: :created, location: @delivery_note }
        else
          format.html { render action: "new" }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /delivery_notes/1
    # PUT /delivery_notes/1.json
    def update
      @breadcrumb = 'update'
      @delivery_note = DeliveryNote.find(params[:id])
      @delivery_note.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @delivery_note.update_attributes(params[:delivery_note])
          format.html { redirect_to @delivery_note,
                        notice: (crud_notice('updated', @delivery_note) + "#{undo_link(@delivery_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /delivery_notes/1
    # DELETE /delivery_notes/1.json
    def destroy
      @delivery_note = DeliveryNote.find(params[:id])

      respond_to do |format|
        if @delivery_note.destroy
          format.html { redirect_to delivery_notes_url,
                      notice: (crud_notice('destroyed', @delivery_note) + "#{undo_link(@delivery_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to delivery_notes_url, alert: "#{@delivery_note.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
