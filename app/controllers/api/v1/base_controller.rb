class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  include StuffModule

  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  before_filter :destroy_session
  before_filter :parse_request

  private

  def destroy_session
    request.session_options[:skip] = true
  end

  def parse_request
    json = request.body.read
    @json = json && json.length >= 2 ? JSON.parse(json) : nil
    #@json = JSON.parse(request.body.read)
  end

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user = user_email && User.find_by_email(user_email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: false
    else
      render json: :unauthorized, status: :unauthorized
    end
  end

  # def authenticate_user_from_token!
  #   if !@json['api_token']
  #     render json: :unauthorized, status: :unauthorized
  #     #render nothing: true, status: :unauthorized
  #   else
  #     @user = nil
  #     User.find_each do |u|
  #       if Devise.secure_compare(u.api_token, @json['api_token'])
  #         @user = u
  #       end
  #     end
  #   end
  # end
end
