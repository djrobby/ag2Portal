class GuideController < ApplicationController
  def index
    @guides = Guide.order(:sort_order)
  end
end
