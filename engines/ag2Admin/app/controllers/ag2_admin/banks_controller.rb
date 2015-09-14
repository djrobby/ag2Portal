require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class BanksController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /banks
    # GET /banks.json
    def index
      manage_filter_state
      @banks = Bank.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @banks }
        format.js
      end
    end
  
    # GET /banks/1
    # GET /banks/1.json
    def show
      @breadcrumb = 'read'
      @bank = Bank.find(params[:id])
      @bank_offices = @bank.bank_offices.order("code")

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @bank }
      end
    end
  
    # GET /banks/new
    # GET /banks/new.json
    def new
      @breadcrumb = 'create'
      @bank = Bank.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @bank }
      end
    end
  
    # GET /banks/1/edit
    def edit
      @breadcrumb = 'update'
      @bank = Bank.find(params[:id])
    end
  
    # POST /banks
    # POST /banks.json
    def create
      @breadcrumb = 'create'
      @bank = Bank.new(params[:bank])
      @bank.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @bank.save
          format.html { redirect_to @bank, notice: crud_notice('created', @bank) }
          format.json { render json: @bank, status: :created, location: @bank }
        else
          format.html { render action: "new" }
          format.json { render json: @bank.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /banks/1
    # PUT /banks/1.json
    def update
      @breadcrumb = 'update'
      @bank = Bank.find(params[:id])
      @bank.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @bank.update_attributes(params[:bank])
          format.html { redirect_to @bank,
                        notice: (crud_notice('updated', @bank) + "#{undo_link(@bank)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @bank.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /banks/1
    # DELETE /banks/1.json
    def destroy
      @bank = Bank.find(params[:id])

      respond_to do |format|
        if @bank.destroy
          format.html { redirect_to banks_url,
                      notice: (crud_notice('destroyed', @bank) + "#{undo_link(@bank)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to banks_url, alert: "#{@bank.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @bank.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      Bank.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
