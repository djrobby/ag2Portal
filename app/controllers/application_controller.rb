class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout

  private

  def layout
    # turn layout off for session and registration pages:
    if is_a?(Devise::SessionsController)
      "session"
    elsif is_a?(Devise::RegistrationsController)
      "registration"
    else
      "application"
    end
    
    # turn it off for registration pages:
    # is_a?(Devise::SessionsController) ? "session" : "application"
    # turn it off for registration pages:
    # is_a?(Devise::RegistrationsController) ? "registration" : "application"
    # or turn layout off for every devise controller:
    # devise_controller? && "application"
    
    # turn it off for welcome page: Controller
  end
end
