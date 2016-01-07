module Ag2Admin
  class ApplicationController < ::ApplicationController
    layout 'layouts/application'

    def reset_session_variables_for_filters
      session[:search] = nil
      session[:letter] = nil
      session[:sort] = nil
      session[:direction] = nil
      session[:ifilter] = nil
    end
  end
end
