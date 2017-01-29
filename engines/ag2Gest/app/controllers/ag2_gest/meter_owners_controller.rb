require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class MeterOwnersController < ApplicationController

    before_filter :authenticate_user!
    load_and_authorize_resource
    helper_method :sort_column

    # GET /meter_owners
    # GET /meter_owners.json
    def index
      manage_filter_state
      @meter_owners = MeterOwner.paginate(:page => params[:page], :per_page => per_page || 10).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @meter_owners }
        format.js
      end
    end

    # GET /meter_owners/1
    # GET /meter_owners/1.json
    def show

      @breadcrumb = 'read'
      @meter_owner = MeterOwner.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @meter_owner }
      end
    end

    # GET /meter_owners/new
    # GET /meter_owners/new.json
    def new
      @breadcrumb = 'create'
      @meter_owner = MeterOwner.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @meter_owner }
      end
    end

    # GET /meter_owners/1/edit
    def edit
      @breadcrumb = 'update'
      @meter_owner = MeterOwner.find(params[:id])
    end

    # POST /meter_owners
    # POST /meter_owners.json
    def create
      @breadcrumb = 'create'
      @meter_owner = MeterOwner.new(params[:meter_owner])
      @meter_owner.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_owner.save
          format.html { redirect_to @meter_owner, notice: t('activerecord.attributes.meter_owner.create') }
          format.json { render json: @meter_owner, status: :created, owner: @meter_owner }
        else
          format.html { render action: "new" }
          format.json { render json: @meter_owner.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /meter_owners/1
    # PUT /meter_owners/1.json
    def update
      @breadcrumb = 'update'
      @meter_owner = MeterOwner.find(params[:id])
      @meter_owner.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @meter_owner.update_attributes(params[:meter_owner])
          format.html { redirect_to @meter_owner,
                        notice: (crud_notice('updated', @meter_owner) + "#{undo_link(@meter_owner)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @meter_owner.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /meter_owners/1
    # DELETE /meter_owners/1.json
    def destroy
      @meter_owner = MeterOwner.find(params[:id])

      respond_to do |format|
        if @meter_owner.destroy
          format.html { redirect_to meter_owners_url,
                      notice: (crud_notice('destroyed', @meter_owner) + "#{undo_link(@meter_owner)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to meter_owners_url, alert: "#{@meter_owner.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @meter_owner.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      MeterOwner.column_names.include?(params[:sort]) ? params[:sort] : "name"
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
