class GuideController < ApplicationController
  def index
    @guides = Guide.order(:sort_order)
    @guide = @guides.first
  end

  # Update content div at view from guide
  def gu_content_from_guide
    guide = Guide.find_by_name(params[:name]) rescue nil
    content = !guide.nil? ? guide.body : nil
    @json_data = { "content" => content }
    render json: @json_data
  end

  # Update content div at view from subguide
  def gu_content_from_subguide
    guide = Subguide.find_by_name(params[:name]) rescue nil
    content = !guide.nil? ? guide.body : nil
    @json_data = { "content" => content }
    render json: @json_data
  end
end
