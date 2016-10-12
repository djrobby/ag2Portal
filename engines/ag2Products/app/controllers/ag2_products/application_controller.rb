module Ag2Products
  class ApplicationController < ::ApplicationController
    mattr_accessor :reset_session_variables_for_filters

    layout 'layouts/application'

    def reset_session_variables_for_filters
      session[:search] = nil
      session[:letter] = nil
      session[:No] = nil
      session[:Type] = nil
      session[:Family] = nil
      session[:Store] = nil
      session[:Measure] = nil
      session[:Manufacturer] = nil
      session[:Tax] = nil
      session[:Client] = nil
      session[:Project] = nil
      session[:Order] = nil
      session[:Account] = nil
      session[:Products] = nil
      session[:Stores] = nil
      session[:Suppliers] = nil
      session[:Companies] = nil
      session[:sort] = nil
      session[:direction] = nil
    end
  end
end
