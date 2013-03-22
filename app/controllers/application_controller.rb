class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout

  private

  def layout
    # only turn it off for login pages:
    is_a?(Devise::SessionsController) ? "login" : "application"
    # or turn layout off for every devise controller:
    # devise_controller? && "application"
  end
end
