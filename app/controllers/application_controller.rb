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
  helper_method :website_path
  helper_method :application_path
  helper_method :sort_direction
  helper_method :init_oco
  helper_method :current_oco

  #
  # OCO
  #
  def init_oco
    if user_signed_in?
      if !session[:office]
        session[:office] = '0'
        session[:exclusive_office] = false
      end
      if !session[:company]
        session[:company] = '0'
        session[:exclusive_company] = false
      end
      if !session[:organization]
        session[:organization] = '0'
        session[:exclusive_organization] = false
      end

      offices = current_user.offices              # O
      companies = current_user.companies          # C
      organizations = current_user.organizations  # O
      
      # Exclusive Office?
      if offices.count == 1
        session[:office] = offices.first.id
        session[:company] = offices.first.company.id
        session[:organization] = offices.first.company.organization.id
        session[:exclusive_office] = true
        session[:exclusive_company] = true
        session[:exclusive_organization] = true
      else
        # Exclusive Company?
        if companies.count == 1
          session[:company] = companies.first.id
          session[:organization] = companies.first.organization.id
          session[:exclusive_company] = true
          session[:exclusive_organization] = true
        else
          # Exclusive Organization?
          if organizations.count == 1
            session[:organization] = organizations.first.id
            session[:exclusive_organization] = true
          end
        end
      end
    end    
  end
  
  def current_oco
    oco = ''
    if session[:office] != '0'
      oco += Office.find(session[:office]).name + ' | '
    end
    if session[:company] != '0'
      oco += Company.find(session[:company]).name
    end
    if session[:organization] != '0'
      if oco == ''
        oco += Organization.find(session[:organization]).name
      else
        oco += ' | ' + Organization.find(session[:organization]).name
      end
    end
    oco
  end
  
  #
  # Display
  #
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
  def website_path(to_site, to_target)
    _navto = Site.find_by_name(to_site)
    if _navto.nil?
      _path = '#notfound'
      _target = '_self'
    else
      _path = 'http://' + _navto.path
      _target = to_target
    end
    return _path, _target
  end

  # App path
  def application_path(to_app, to_target)
    _navto = App.find_by_name(to_app)
    if _navto.nil?
      _path = '#notfound'
      _target = '_self'
    else
      _path = 'http://' + _navto.path
      _target = to_target
    end
    return _path, _target
  end

  # Table (index) sort
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  # Char set
  def set_locale
    # I18n.locale = params[:locale] || I18n.default_locale
    I18n.locale = params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
  end

  def self.default_url_options
    { :locale => I18n.locale }
  end

  #
  # Control digits
  #
  # CIF/NIF
  # Returns DC if no exception
  # Exceptions:
  # => $err = Calculation error
  # => $par = Parameter error
  def fiscal_id_dc(fiscal_id)
    _dc = ''
    fiscal_id.strip!
    fiscal_id.upcase!
    fiscal_id.delete! ' /-'
    if fiscal_id.length < 8 || fiscal_id.length > 9
      _dc = '$par'
    else
      if is_numeric?(fiscal_id[0])
        # NIF
        _dc = calc_dc_individual(fiscal_id.to_i)
      elsif fiscal_id[0] == 'X'
        # NIE
        _dc = calc_dc_individual(fiscal_id[1, fiscal_id.length-1].to_i)
      elsif fiscal_id[0] == 'U'
        # UTE
        _dc = '$ute'
      elsif ('ABCDEFGHKLMNPQS'.index fiscal_id[0]) != nil
        # CIF
        _dc = calc_dc_legal_entity(fiscal_id)
      else
        _dc = '$err'
      end
    end
    _dc
  end
  
  def fiscal_id_description(code)
    _m = 'ERROR'
    code = '0' if is_numeric?(code)
    _d = FiscalDescription.find_by_code(code)
    if !_d.nil?
      _m = _d.name
    end
    _m
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

  # IS NUMERIC
  def is_numeric?(object)
    true if Float(object) rescue false
  end  
  
  # NIF/NIE
  def calc_dc_individual(fiscal_id)
    'TRWAGMYFPDXBNJZSQVHLCKE'[fiscal_id % 23, 1]
  end
  # CIF
  def calc_dc_legal_entity(fiscal_id)
    _dc = ''
    _l = 0
    _c = '0246813579'
    _l += _c[fiscal_id[1].to_i].to_i + fiscal_id[2].to_i
    _l += _c[fiscal_id[3].to_i].to_i + fiscal_id[4].to_i
    _l += _c[fiscal_id[5].to_i].to_i + fiscal_id[6].to_i
    _l += _c[fiscal_id[7].to_i].to_i
    _l = 10 - (_l % 10)
    if _l == 10
      _dc = 'J0'
    else
      _dc = (_l + 64).chr + _l.to_s
    end
    if _dc[0] == fiscal_id[8]
      _dc = _dc[0]
    elsif _dc[1] == fiscal_id[8]
      _dc = _dc[1]
    else
      _dc = '$err'
    end
    _dc
  end

  # BROWSER CURRENT LOCALE
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  # SETUP LAYOUT
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
