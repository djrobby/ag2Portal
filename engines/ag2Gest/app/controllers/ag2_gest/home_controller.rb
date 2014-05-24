require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
    end
  end
end
