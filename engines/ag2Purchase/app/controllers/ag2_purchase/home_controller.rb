require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
      session[:No] = nil      
      session[:Supplier] = nil      
      session[:Status] = nil
      session[:Project] = nil      
      session[:Order] = nil
      session[:Invoice] = nil
      session[:Products] = nil
      session[:Suppliers] = nil      
      session[:sort] = nil
      session[:direction] = nil      
      session[:ifilter] = nil      
    end
  end
end
