require_dependency "ag2_human/application_controller"

module Ag2Human
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
      session[:WrkrCompany] = nil
      session[:WrkrOffice] = nil      
      session[:Worker] = nil
      session[:From] = nil      
      session[:To] = nil
      session[:Type] = nil      
      session[:Code] = nil      
      session[:sort] = nil
      session[:direction] = nil      
    end
  end
end
