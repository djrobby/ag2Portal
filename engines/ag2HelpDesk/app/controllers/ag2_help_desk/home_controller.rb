require_dependency "ag2_help_desk/application_controller"

module Ag2HelpDesk
  class HomeController < ApplicationController
    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
    end
  end
end
