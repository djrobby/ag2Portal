require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class ProcessedFilesController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource
    skip_load_and_authorize_resource :only => []
    helper_method :sort_column

    #
    # Default Methods
    #
    # GET /processed_files
    # GET /processed_files.json
    def index
      @processed_files = ProcessedFile.paginate(:page => params[:page], :per_page => per_page)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @processed_files }
        format.js
      end
    end

    # GET /processed_files/1
    # GET /processed_files/1.json
    def show
      @breadcrumb = 'read'
      @processed_file = ProcessedFile.find(params[:id])
      @processed_file_items = @processed_file.processed_file_items.paginate(:page => params[:page], :per_page => per_page)

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @processed_file }
      end
    end

    private

  end
end
