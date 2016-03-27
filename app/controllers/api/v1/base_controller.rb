class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_filter :destroy_session
  #before_filter :parse_request, :authenticate_user_from_token!

  private

  def destroy_session
    request.session_options[:skip] = true
  end

  def parse_request
    @json = JSON.parse(request.body.read)
  end

  def authenticate_user_from_token!
    if !@json['api_token']
      render json: :unauthorized, status: :unauthorized
      #render nothing: true, status: :unauthorized
    else
      @user = nil
      User.find_each do |u|
        if Devise.secure_compare(u.api_token, @json['api_token'])
          @user = u
        end
      end
    end
  end
end
