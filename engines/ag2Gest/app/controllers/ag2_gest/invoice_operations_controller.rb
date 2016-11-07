require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class InvoiceOperationsController < ApplicationController

        helper_method :sort_column
        before_filter :authenticate_user!
        load_and_authorize_resource

        # GET /invoice_operations
        # GET /invoice_operations.json
        def index
          manage_filter_state
          @invoice_operations = InvoiceOperation.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

          respond_to do |format|
            format.html # index.html.erb
            format.json { render json: @invoice_operations }
            format.js
          end
        end

        # GET /invoice_operations/1
        # GET /invoice_operations/1.json
        def show
          @breadcrumb = 'read'
          @invoice_operation = InvoiceOperation.find(params[:id])

          respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @invoice_operation }
          end
        end

        # GET /invoice_operations/new
        # GET /invoice_operations/new.json
        def new

          @breadcrumb = 'create'
          @invoice_operation = InvoiceOperation.new

          respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @invoice_operation }
          end
        end

        # GET /invoice_operations/1/edit
        def edit
          @breadcrumb = 'update'
          @invoice_operation = InvoiceOperation.find(params[:id])
        end

        # POST /invoice_operations
        # POST /invoice_operations.json
        def create
          @breadcrumb = 'create'
          @invoice_operation = InvoiceOperation.new(params[:invoice_operation])
          @invoice_operation.created_by = current_user.id if !current_user.nil?

          respond_to do |format|
            if @invoice_operation.save
              format.html { redirect_to @invoice_operation, notice: t('activerecord.attributes.invoice_operation.create') }
              format.json { render json: @invoice_operation, operation: :created, location: @invoice_operation }
            else
              format.html { render action: "new" }
              format.json { render json: @invoice_operation.errors, operation: :unprocessable_entity }
            end
          end
        end

        # PUT /invoice_operations/1
        # PUT /invoice_operations/1.json
        def update
          @breadcrumb = 'update'
          @invoice_operation = InvoiceOperation.find(params[:id])
          @invoice_operation.updated_by = current_user.id if !current_user.nil?

          respond_to do |format|
            if @invoice_operation.update_attributes(params[:invoice_operation])
              format.html { redirect_to @invoice_operation, notice: t('activerecord.attributes.invoice_operation.successfully') }
              format.json { head :no_content }
            else
              format.html { render action: "edit" }
              format.json { render json: @invoice_operation.errors, operation: :unprocessable_entity }
            end
          end
        end

        # DELETE /invoice_operations/1
        # DELETE /invoice_operations/1.json
        def destroy
          @invoice_operation = InvoiceOperation.find(params[:id])
          @invoice_operation.destroy

          respond_to do |format|
            format.html { redirect_to invoice_operations_url }
            format.json { head :no_content }
          end
        end

        private

        def sort_column
          InvoiceOperation.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
