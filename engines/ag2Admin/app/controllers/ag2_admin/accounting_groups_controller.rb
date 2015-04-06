require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class AccountingGroupsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /accounting_groups
    # GET /accounting_groups.json
    def index
      manage_filter_state
      @accounting_groups = AccountingGroup.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @accounting_groups }
        format.js
      end
    end
  
    # GET /accounting_groups/1
    # GET /accounting_groups/1.json
    def show
      @breadcrumb = 'read'
      @accounting_group = AccountingGroup.find(params[:id])
      @ledger_accounts = @accounting_group.ledger_accounts.order("code")
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @accounting_group }
      end
    end
  
    # GET /accounting_groups/new
    # GET /accounting_groups/new.json
    def new
      @breadcrumb = 'create'
      @accounting_group = AccountingGroup.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @accounting_group }
      end
    end
  
    # GET /accounting_groups/1/edit
    def edit
      @breadcrumb = 'update'
      @accounting_group = AccountingGroup.find(params[:id])
    end
  
    # POST /accounting_groups
    # POST /accounting_groups.json
    def create
      @breadcrumb = 'create'
      @accounting_group = AccountingGroup.new(params[:accounting_group])
      @accounting_group.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @accounting_group.save
          format.html { redirect_to @accounting_group, notice: crud_notice('created', @accounting_group) }
          format.json { render json: @accounting_group, status: :created, location: @accounting_group }
        else
          format.html { render action: "new" }
          format.json { render json: @accounting_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /accounting_groups/1
    # PUT /accounting_groups/1.json
    def update
      @breadcrumb = 'update'
      @accounting_group = AccountingGroup.find(params[:id])
      @accounting_group.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @accounting_group.update_attributes(params[:accounting_group])
          format.html { redirect_to @accounting_group,
                        notice: (crud_notice('updated', @accounting_group) + "#{undo_link(@accounting_group)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @accounting_group.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /accounting_groups/1
    # DELETE /accounting_groups/1.json
    def destroy
      @accounting_group = AccountingGroup.find(params[:id])

      respond_to do |format|
        if @accounting_group.destroy
          format.html { redirect_to accounting_groups_url,
                      notice: (crud_notice('destroyed', @accounting_group) + "#{undo_link(@accounting_group)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to accounting_groups_url, alert: "#{@accounting_group.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @accounting_group.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      AccountingGroup.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
