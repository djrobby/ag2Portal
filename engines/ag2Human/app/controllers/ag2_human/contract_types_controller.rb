require_dependency "ag2_human/application_controller"

module Ag2Human
  class ContractTypesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    # Helper methods for sorting
    helper_method :sort_column
    # GET /contract_types
    # GET /contract_types.json
    def index
      @contract_types = ContractType.paginate(:page => params[:page], :per_page => per_page).order(sort_column + ' ' + sort_direction)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @contract_types }
      end
    end

    # GET /contract_types/1
    # GET /contract_types/1.json
    def show
      @breadcrumb = 'read'
      @contract_type = ContractType.find(params[:id])
      @workers = @contract_type.workers.paginate(:page => params[:page], :per_page => per_page).order('worker_code')

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @contract_type }
      end
    end

    # GET /contract_types/new
    # GET /contract_types/new.json
    def new
      @breadcrumb = 'create'
      @contract_type = ContractType.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @contract_type }
      end
    end

    # GET /contract_types/1/edit
    def edit
      @breadcrumb = 'update'
      @contract_type = ContractType.find(params[:id])
    end

    # POST /contract_types
    # POST /contract_types.json
    def create
      @breadcrumb = 'create'
      @contract_type = ContractType.new(params[:contract_type])
      @contract_type.created_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contract_type.save
          format.html { redirect_to @contract_type, notice: crud_notice('created', @contract_type) }
          format.json { render json: @contract_type, status: :created, location: @contract_type }
        else
          format.html { render action: "new" }
          format.json { render json: @contract_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /contract_types/1
    # PUT /contract_types/1.json
    def update
      @breadcrumb = 'update'
      @contract_type = ContractType.find(params[:id])
      @contract_type.updated_by = current_user.id if !current_user.nil?

      respond_to do |format|
        if @contract_type.update_attributes(params[:contract_type])
          format.html { redirect_to @contract_type,
                        notice: (crud_notice('updated', @contract_type) + "#{undo_link(@contract_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contract_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /contract_types/1
    # DELETE /contract_types/1.json
    def destroy
      @contract_type = ContractType.find(params[:id])

      respond_to do |format|
        if @contract_type.destroy
          format.html { redirect_to contract_types_url,
                      notice: (crud_notice('destroyed', @contract_type) + "#{undo_link(@contract_type)}").html_safe }
          format.json { head :no_content }
        else
          format.html { redirect_to contract_types_url, alert: "#{@contract_type.errors[:base].to_s}".gsub('["', '').gsub('"]', '') }
          format.json { render json: @contract_type.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def sort_column
      ContractType.column_names.include?(params[:sort]) ? params[:sort] : "ct_code"
    end
  end
end
