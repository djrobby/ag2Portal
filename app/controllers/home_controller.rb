class HomeController < ApplicationController
  # include StuffModule

  # before_filter :authenticate_user_from_token!

  def index
    @ag2teamnet_path, @ag2teamnet_target = website_path('ag2TeamNet', '_self')
  end
end
