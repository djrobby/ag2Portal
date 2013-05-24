require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ConfigController < ApplicationController
    before_filter :authenticate_user!
    def index
      authorize! :manage, User

      # Path for ag2Db app
      app = App.find_by_name('ag2Db')
      if app.nil?
        @ag2db_path = '#notfound'
        @target = '_self'
      else
        @ag2db_path = 'http://' + app.path
        @target = '_blank'
      end
    end
  end
end
