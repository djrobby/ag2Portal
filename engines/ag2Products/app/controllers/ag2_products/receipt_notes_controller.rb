require_dependency "ag2_products/application_controller"

module Ag2Products
  class ReceiptNotesController < ApplicationController
    include ActionView::Helpers::NumberHelper
    before_filter :authenticate_user!
    load_and_authorize_resource

    #
    # Default Methods
    #
    # GET /supplier_invoices
    # GET /supplier_invoices.json
    # GET /receipt_notes
    # GET /receipt_notes.json
    def index
      supplier = params[:Supplier]
      project = params[:Project]
      order = params[:Order]

      @search = ReceiptNote.search do
        fulltext params[:search]
        if !supplier.blank?
          with :supplier_id, supplier
        end
        if !project.blank?
          with :project_id, project
        end
        if !order.blank?
          with :work_order_id, order
        end
        order_by :id, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @receipt_notes = @search.results

      # Initialize select_tags
      @suppliers = Supplier.order('name') if @suppliers.nil?
      @projects = Project.order('project_code') if @projects.nil?
      @work_orders = WorkOrder.order('order_no') if @work_orders.nil?
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @receipt_notes }
      end
    end
  
    # GET /receipt_notes/1
    # GET /receipt_notes/1.json
    def show
      @breadcrumb = 'read'
      @receipt_note = ReceiptNote.find(params[:id])
      @items = @receipt_note.receipt_note_items.paginate(:page => params[:page], :per_page => per_page).order('id')
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/new
    # GET /receipt_notes/new.json
    def new
      @breadcrumb = 'create'
      @receipt_note = ReceiptNote.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @receipt_note }
      end
    end
  
    # GET /receipt_notes/1/edit
    def edit
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])
    end
  
    # POST /receipt_notes
    # POST /receipt_notes.json
    def create
      @breadcrumb = 'create'
      @receipt_note = ReceiptNote.new(params[:receipt_note])
      @receipt_note.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @receipt_note.save
          format.html { redirect_to @receipt_note, notice: crud_notice('created', @receipt_note) }
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
      @breadcrumb = 'update'
      @receipt_note = ReceiptNote.find(params[:id])
      @receipt_note.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @receipt_note.update_attributes(params[:receipt_note])
          format.html { redirect_to @receipt_note,
                        notice: (crud_notice('updated', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
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

      respond_to do |format|
        if @receipt_note.destroy
          format.html { redirect_to receipt_notes_url,
                      notice: (crud_notice('destroyed', @receipt_note) + "#{undo_link(@receipt_note)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to receipt_notes_url, alert: "#{@receipt_note.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @receipt_note.errors, status: :unprocessable_entity }
        end
      end
    end
  end
end
