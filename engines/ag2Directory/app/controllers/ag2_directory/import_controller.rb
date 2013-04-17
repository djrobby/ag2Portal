require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class ImportController < ApplicationController
    def index
    end
    
    def data_import
      message = "Corporate Contacts Updater finished succesfully.".html_safe
      sleep 2
      @json_data = { "DataImport" => message }
      render json: @json_data
    end
  end
end
