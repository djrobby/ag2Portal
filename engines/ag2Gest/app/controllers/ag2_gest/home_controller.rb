require_dependency "ag2_gest/application_controller"

module Ag2Gest
  class HomeController < ApplicationController
    before_filter :reset_session_variables

    def index
      @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
      #reset_session_variables_for_filters
    end

    def reset_session_variables
      reset_session_variables_for_filters
    end
  end
end
