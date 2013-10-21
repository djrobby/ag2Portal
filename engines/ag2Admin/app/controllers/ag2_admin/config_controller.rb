require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ConfigController < ApplicationController
    before_filter :authenticate_user!
    def index
      authorize! :manage, User    # Authorize only if current user can manage User model

      # Path for ag2Db app
      @ag2db_path, @target = application_path('ag2Db', '_blank')
    end
  end
end
