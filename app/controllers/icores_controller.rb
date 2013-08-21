class IcoresController < ApplicationController
  def index
    @ag2teamnet_path, @ag2teamnet_target = site_path('ag2TeamNet', '_self')
  end
end
