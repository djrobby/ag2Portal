module Ag2HelpDesk
  class ApplicationController < ::ApplicationController
    mattr_accessor :reset_session_variables_for_filters

    layout 'layouts/application'

    def reset_session_variables_for_filters
      session[:search] = nil
      session[:Id] = nil
      session[:User] = nil
      session[:OfficeT] = nil
      session[:From] = nil
      session[:To] = nil
      session[:Category] = nil
      session[:Priority] = nil
      session[:Status] = nil
      session[:Technician] = nil
      session[:Domain] = nil
      session[:sort] = nil
      session[:direction] = nil
    end
  end
end
