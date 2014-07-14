require_dependency "ag2_purchase/application_controller"

module Ag2Purchase
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      session[:search] = nil
      session[:letter] = nil      
    end
  end
end
