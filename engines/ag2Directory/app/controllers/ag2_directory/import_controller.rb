require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class ImportController < ApplicationController
    def index
    end
    
    def data_import
      @json_data = { "Percentage" => "50" }
      render json: @json_data

      #@json_data = { "DataImport" => "OK" }
      #render json: @json_data
    end
  end
end
