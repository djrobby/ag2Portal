class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  # before_filter :set_charset
  before_filter :set_locale

  layout :layout
  helper_method :letters
  helper_method :per_page
  helper_method :undo_link
  helper_method :crud_notice
  helper_method :site_path

  def letters
    @letters = ('A'..'Z')
  end

  def per_page
    if session[:resolution] == "LD"
    20
    elsif session[:resolution] == "SD"
    40
    else
    60
    end
  end

  # Configure link_to 'undo' to be displayed on notification
  # (rails flash) area (messages layout) at the current view_context
  # and routes to VersionsController#revert
  #
  # At Controllers: "#{undo_link(@<controller_ivar>)}"
  def undo_link(ivar)
    view_context.link_to("<i class='icon-undo-black'></i>".html_safe,
    main_app.revert_version_path(ivar.versions.scoped.last),
    :method => :post, :class => 'notice-icon-button',
    :id => 'undo', :title => I18n.t(:undo))
  end

  # Notification messages from create, read, update & destroy actions
  def crud_notice(action, ivar)
    if action == "created"
      I18n.t('activerecord.successful.messages.created', :model => ivar.class.model_name.human)
    elsif action == "updated"
      I18n.t('activerecord.successful.messages.updated', :model => ivar.class.model_name.human)
    elsif action == "destroyed"
      I18n.t('activerecord.successful.messages.destroyed', :model => ivar.class.model_name.human)
    else # read
      "Read"
    end
  end

  # Site path
  def site_path(to_site, to_target)
    site = Site.find_by_name(to_site)
    if site.nil?
      site_path = '#notfound'
      site_target = '_self'
    else
      site_path = 'http://' + site.path
      site_target = to_target
    end
    return site_path, site_target
  end
  
  def set_locale
    # I18n.locale = params[:locale] || I18n.default_locale
    I18n.locale = params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
  end

  def self.default_url_options
    { :locale => I18n.locale }
  end

=begin
def default_url_options(options={})
# logger.debug "default_url_options is passed options: #{options.inspect}\n"
{ :locale => I18n.locale }
end

def set_charset
# @headers["Content-Type"] = "text/html; charset=utf-8"
end
=end

  private

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def layout
    # turn layout off for session and registration pages
    # and on for the others
    if is_a?(Devise::SessionsController)
      "session"
    elsif is_a?(Devise::RegistrationsController)
      if user_signed_in?
        "profile"
      else
        "registration"
      end
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
