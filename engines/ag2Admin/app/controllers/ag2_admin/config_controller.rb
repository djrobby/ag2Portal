require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ConfigController < ApplicationController
    before_filter :authenticate_user!
    
    def index
      authorize! :manage, User
    end
  end
end
