require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ChargeAccountsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column

    # GET /charge_accounts
    # GET /charge_accounts.json
    def index
      @charge_accounts = ChargeAccount.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @charge_accounts }
      end
    end
  
    # GET /charge_accounts/1
    # GET /charge_accounts/1.json
    def show
      @breadcrumb = 'read'
      @charge_account = ChargeAccount.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/new
    # GET /charge_accounts/new.json
    def new
      @breadcrumb = 'create'
      @charge_account = ChargeAccount.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/1/edit
    def edit
      @breadcrumb = 'update'
      @charge_account = ChargeAccount.find(params[:id])
    end
  
    # POST /charge_accounts
    # POST /charge_accounts.json
    def create
      @breadcrumb = 'create'
      @charge_account = ChargeAccount.new(params[:charge_account])
      @charge_account.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_account.save
          format.html { redirect_to @charge_account, notice: crud_notice('created', @charge_account) }
          format.json { render json: @charge_account, status: :created, location: @charge_account }
        else
          format.html { render action: "new" }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /charge_accounts/1
    # PUT /charge_accounts/1.json
    def update
      @breadcrumb = 'update'
      @charge_account = ChargeAccount.find(params[:id])
      @charge_account.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @charge_account.update_attributes(params[:charge_account])
          format.html { redirect_to @charge_account,
                        notice: (crud_notice('updated', @charge_account) + "#{undo_link(@charge_account)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /charge_accounts/1
    # DELETE /charge_accounts/1.json
    def destroy
      @charge_account = ChargeAccount.find(params[:id])

      respond_to do |format|
        if @charge_account.destroy
          format.html { redirect_to charge_accounts_url,
                      notice: (crud_notice('destroyed', @charge_account) + "#{undo_link(@charge_account)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to charge_accounts_url, alert: "#{@charge_account.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @charge_account.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ChargeAccount.column_names.include?(params[:sort]) ? params[:sort] : "account_code"
    end
  end
end
