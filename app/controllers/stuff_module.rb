module StuffModule
  #
  # Returns true if object is numeric
  #
  def is_numeric?(object)
    true if Float(object) rescue false
  end

  #
  # Sign in if auth token is received as parameter
  # It parameter is received but User doesn't exist, authenticate user
  #
  def authenticate_user_from_token!
    if params.has_key?(:auth_token)
      user_token = params[:auth_token]
      user = User.find_by_authentication_token(user_token.to_s) rescue nil
      if !user.nil?
        sign_in user
      else
        authenticate_user!
      end
    end
  end
end
