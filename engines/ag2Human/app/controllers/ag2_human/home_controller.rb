require_dependency "ag2_human/application_controller"

module Ag2Human
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
      session[:Company] = nil
      session[:Office] = nil      
    end
  end
end
