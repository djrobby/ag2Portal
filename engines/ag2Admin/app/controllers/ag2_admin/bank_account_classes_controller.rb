require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class BankAccountClassesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /bank_account_classes
    # GET /bank_account_classes.json
    def index
      manage_filter_state
      @bank_account_classes = BankAccountClass.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @bank_account_classes }
        format.js
      end
    end
  
    # GET /bank_account_classes/1
    # GET /bank_account_classes/1.json
    def show
      @breadcrumb = 'read'
      @bank_account_class = BankAccountClass.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @bank_account_class }
      end
    end
  
    # GET /bank_account_classes/new
    # GET /bank_account_classes/new.json
    def new
      @breadcrumb = 'create'
      @bank_account_class = BankAccountClass.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @bank_account_class }
      end
    end
  
    # GET /bank_account_classes/1/edit
    def edit
      @breadcrumb = 'update'
      @bank_account_class = BankAccountClass.find(params[:id])
    end
  
    # POST /bank_account_classes
    # POST /bank_account_classes.json
    def create
      @breadcrumb = 'create'
      @bank_account_class = BankAccountClass.new(params[:bank_account_class])
      @bank_account_class.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @bank_account_class.save
          format.html { redirect_to @bank_account_class, notice: crud_notice('created', @bank_account_class) }
          format.json { render json: @bank_account_class, status: :created, location: @bank_account_class }
        else
          format.html { render action: "new" }
          format.json { render json: @bank_account_class.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /bank_account_classes/1
    # PUT /bank_account_classes/1.json
    def update
      @breadcrumb = 'update'
      @bank_account_class = BankAccountClass.find(params[:id])
      @bank_account_class.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @bank_account_class.update_attributes(params[:bank_account_class])
          format.html { redirect_to @bank_account_class,
                        notice: (crud_notice('updated', @bank_account_class) + "#{undo_link(@bank_account_class)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @bank_account_class.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /bank_account_classes/1
    # DELETE /bank_account_classes/1.json
    def destroy
      @bank_account_class = BankAccountClass.find(params[:id])

      respond_to do |format|
        if @bank_account_class.destroy
          format.html { redirect_to bank_account_classes_url,
                      notice: (crud_notice('destroyed', @bank_account_class) + "#{undo_link(@bank_account_class)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to bank_account_classes_url, alert: "#{@bank_account_class.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @bank_account_class.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      BankAccountClass.column_names.include?(params[:sort]) ? params[:sort] : "id"
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
