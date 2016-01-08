module Ag2Human
  class ApplicationController < ::ApplicationController
    mattr_accessor :reset_session_variables_for_filters

    layout 'layouts/application'

    def reset_session_variables_for_filters
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
