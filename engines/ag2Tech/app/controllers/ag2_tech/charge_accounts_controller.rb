require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class ChargeAccountsController < ApplicationController
    # GET /charge_accounts
    # GET /charge_accounts.json
    def index
      @charge_accounts = ChargeAccount.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @charge_accounts }
      end
    end
  
    # GET /charge_accounts/1
    # GET /charge_accounts/1.json
    def show
      @charge_account = ChargeAccount.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/new
    # GET /charge_accounts/new.json
    def new
      @charge_account = ChargeAccount.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @charge_account }
      end
    end
  
    # GET /charge_accounts/1/edit
    def edit
      @charge_account = ChargeAccount.find(params[:id])
    end
  
    # POST /charge_accounts
    # POST /charge_accounts.json
    def create
      @charge_account = ChargeAccount.new(params[:charge_account])
  
      respond_to do |format|
        if @charge_account.save
          format.html { redirect_to @charge_account, notice: 'Charge account was successfully created.' }
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
      @charge_account = ChargeAccount.find(params[:id])
  
      respond_to do |format|
        if @charge_account.update_attributes(params[:charge_account])
          format.html { redirect_to @charge_account, notice: 'Charge account was successfully updated.' }
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
      @charge_account.destroy
  
      respond_to do |format|
        format.html { redirect_to charge_accounts_url }
        format.json { head :no_content }
      end
    end
  end
end
