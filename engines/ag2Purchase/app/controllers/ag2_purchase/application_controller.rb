module Ag2Purchase
  class ApplicationController < ::ApplicationController
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
    end
  end
end
