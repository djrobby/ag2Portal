require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
      session[:ContactType] = nil      
      session[:sort] = nil
      session[:direction] = nil      
    end
  end
end
