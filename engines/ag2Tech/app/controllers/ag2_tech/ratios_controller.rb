require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class RatiosController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => [:ra_update_group_from_organization,
                                               :ra_generate_code]
    # Helper methods for sorting
    helper_method :sort_column
    
    # Update project text fields at view from organization select
    def ra_update_group_from_organization
      organization = params[:org]
      if organization != '0'
        @organization = Organization.find(organization)
        @groups = @organization.blank? ? groups_dropdown : @organization.ratio_groups.order(:code)
      else
        @groups = groups_dropdown
      end
      @json_data = { "groups" => @groups }
      render json: @json_data
    end

    # Update code at view (generate_code_btn)
    def ra_generate_code
      group = params[:group]
      organization = params[:org]

      # Builds code, if possible
      if group == '$' || organization == '$'
        code = '$err'
      else
        code = ra_next_code(organization, group)
      end
      @json_data = { "code" => code }
      render json: @json_data
    end

    #
    # Default Methods
    #
    # GET /ratios
    # GET /ratios.json
    def index
      manage_filter_state
      init_oco if !session[:organization]
  
      @search = Ratio.search do
        fulltext params[:search]
        if session[:organization] != '0'
          with :organization_id, session[:organization]
        end
        order_by :code, :asc
        paginate :page => params[:page] || 1, :per_page => per_page
      end
      @ratios = @search.results

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @ratios }
        format.js
      end
    end
  
    # GET /ratios/1
    # GET /ratios/1.json
    def show
      @breadcrumb = 'read'
      @ratio = Ratio.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ratio }
      end
    end
  
    # GET /ratios/new
    # GET /ratios/new.json
    def new
      @breadcrumb = 'create'
      @ratio = Ratio.new
      @groups = groups_dropdown
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @ratio }
      end
    end
  
    # GET /ratios/1/edit
    def edit
      @breadcrumb = 'update'
      @ratio = Ratio.find(params[:id])
      @groups = @ratio.organization.blank? ? groups_dropdown : @ratio.organization.ratio_groups.order(:code)
    end
  
    # POST /ratios
    # POST /ratios.json
    def create
      @breadcrumb = 'create'
      @ratio = Ratio.new(params[:ratio])
      @ratio.created_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @ratio.save
          format.html { redirect_to @ratio, notice: crud_notice('created', @ratio) }
          format.json { render json: @ratio, status: :created, location: @ratio }
        else
          @groups = groups_dropdown
          format.html { render action: "new" }
          format.json { render json: @ratio.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /ratios/1
    # PUT /ratios/1.json
    def update
      @breadcrumb = 'update'
      @ratio = Ratio.find(params[:id])
      @ratio.updated_by = current_user.id if !current_user.nil?
  
      respond_to do |format|
        if @ratio.update_attributes(params[:ratio])
          format.html { redirect_to @ratio,
                        notice: (crud_notice('updated', @ratio) + "#{undo_link(@ratio)}").html_safe }
          format.json { head :no_content }
        else
          @groups = @ratio.organization.blank? ? groups_dropdown : @ratio.organization.ratio_groups.order(:code)
          format.html { render action: "edit" }
          format.json { render json: @ratio.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /ratios/1
    # DELETE /ratios/1.json
    def destroy
      @ratio = Ratio.find(params[:id])

      respond_to do |format|
        if @ratio.destroy
          format.html { redirect_to ratios_url,
                      notice: (crud_notice('destroyed', @ratio) + "#{undo_link(@ratio)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to ratios_url, alert: "#{@ratio.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @ratio.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def groups_dropdown
      session[:organization] != '0' ? RatioGroup.where(organization_id: session[:organization].to_i).order(:code) : RatioGroup.order(:code)
    end

    def sort_column
      Ratio.column_names.include?(params[:sort]) ? params[:sort] : "code"
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
