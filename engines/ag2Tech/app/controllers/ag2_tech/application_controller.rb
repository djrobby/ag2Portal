module Ag2Tech
  class ApplicationController < ::ApplicationController
    layout 'layouts/application'

    def reset_session_variables_for_filters
      session[:search] = nil
      session[:letter] = nil
      session[:No] = nil
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
