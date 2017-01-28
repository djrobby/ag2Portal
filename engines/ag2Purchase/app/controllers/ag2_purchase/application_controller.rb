module Ag2Purchase
  class ApplicationController < ::ApplicationController
    mattr_accessor :reset_session_variables_for_filters

    layout 'layouts/application'

    def reset_session_variables_for_filters
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
      session[:Petitioner] = nil
      session[:Balance] = nil
    end
  end
end
