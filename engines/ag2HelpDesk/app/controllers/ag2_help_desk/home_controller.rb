require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:Id] = nil      
      session[:User] = nil
      session[:Office] = nil      
      session[:From] = nil      
      session[:To] = nil
      session[:Category] = nil
      session[:Priority] = nil      
      session[:Status] = nil      
      session[:Technician] = nil      
      session[:sort] = nil
      session[:direction] = nil      
    end
  end
end
