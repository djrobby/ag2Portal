require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class InvoiceTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for
    #  => sorting
    helper_method :sort_column
    # => allow edit (hide buttons)
    helper_method :cannot_edit

    # GET /invoice_types
    # GET /invoice_types.json
    def index
      manage_filter_state
      @invoice_types = InvoiceType.paginate(:page => params[:page], :per_page => 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @invoice_types }
        format.js
      end
    end

    # GET /invoice_types/1
    # GET /invoice_types/1.json
    def show
      @breadcrumb = 'read'
      @invoice_type = InvoiceType.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @invoice_type }
      end
    end

    # GET /invoice_types/new
    # GET /invoice_types/new.json
    def new
      @breadcrumb = 'create'
      @invoice_type = InvoiceType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @invoice_type }
      end
    end

    # GET /invoice_types/1/edit
    def edit
      @breadcrumb = 'update'
      @invoice_type = InvoiceType.find(params[:id])
    end

    # POST /invoice_types
    # POST /invoice_types.json
    def create
      @breadcrumb = 'create'
      @invoice_type = InvoiceType.new(params[:invoice_type])
      @invoice_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @invoice_type.save
          format.html { redirect_to @invoice_type, notice: t('activerecord.attributes.invoice_type.create') }
          format.json { render json: @invoice_type, status: :created, location: @invoice_type }
        else
          format.html { render action: "new" }
          format.json { render json: @invoice_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /invoice_types/1
    # PUT /invoice_types/1.json
    def update
      @breadcrumb = 'update'
      @invoice_type = InvoiceType.find(params[:id])
      @invoice_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @invoice_type.update_attributes(params[:invoice_type])
          format.html { redirect_to @invoice_type, notice: crud_notice('created', @invoice_type) }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @invoice_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /invoice_types/1
    # DELETE /invoice_types/1.json
    def destroy
      @invoice_type = InvoiceType.find(params[:id])

      respond_to do |format|
        if @invoice_type.destroy
          format.html { redirect_to @invoice_type,
                        notice: (crud_notice('updated', @invoice_type) + "#{undo_link(@invoice_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to invoice_types_url, alert: "#{@invoice_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @invoice_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    # Can't edit or delete when
    # => User isn't administrator
    # => Invoice type ID is less than 5
    def cannot_edit(_order)
      !session[:is_administrator] && _order.id < 6
    end

    def sort_column
      InvoiceType.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
