require_dependency "ag2_products/application_controller"

module Ag2Products
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
      session[:Type] = nil      
      session[:Family] = nil
      session[:Measure] = nil      
      session[:Manufacturer] = nil
      session[:Tax] = nil      
      session[:Client] = nil      
      session[:Project] = nil
      session[:Order] = nil      
      session[:Products] = nil
      session[:Stores] = nil      
      session[:Suppliers] = nil      
      session[:sort] = nil
      session[:direction] = nil      
    end
  end
end
