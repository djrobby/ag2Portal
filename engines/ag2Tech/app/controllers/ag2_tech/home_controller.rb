require_dependency "ag2_tech/application_controller"

module Ag2Tech
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
      session[:Project] = nil      
      session[:Type] = nil
      session[:Status] = nil
      session[:WrkrCompany] = nil
      session[:WrkrOffice] = nil      
      session[:sort] = nil
      session[:direction] = nil      
      session[:ifilter] = nil      
      session[:Period] = nil      
      session[:Group] = nil      
    end
  end
end
