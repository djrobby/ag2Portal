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

  def slow_per_page
    if session[:resolution] == "LD"
    10
    elsif session[:resolution] == "SD"
    20
    else
    30
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
  # Attachments
  #
  # Destroy previous attachment
  def destroy_attachment
    a = Attachment.find(1) rescue nil
    if !a.nil?
      a.destroy
    end  
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
    if fiscal_id[0] == '_'
      # Other unidentified
      _dc = '$uni'
    else
      if fiscal_id.length < 8 || fiscal_id.length > 9
        _dc = '$par'
      else
        if is_numeric?(fiscal_id[0])
          # NIF
          _dc = calc_dc_individual(fiscal_id.to_i)
          if fiscal_id.length == 9 && fiscal_id[8] != _dc
            _dc = '$err'
          end
        elsif fiscal_id[0] == 'X'
          # NIE
          _dc = calc_dc_individual(fiscal_id[1, fiscal_id.length-1].to_i)
        elsif fiscal_id[0] == 'U'
          # UTE
          _dc = '$ute'
        elsif ('ABCDEFGHKLMNPQS'.index fiscal_id[0]) != nil
          # CIF
          _dc = calc_dc_legal_entity(fiscal_id)
        elsif fiscal_id[0] == '*'
          # Other unidentified
          _dc = '$uni'
        else
          _dc = '$err'
        end
      end
    end
    _dc
  end
  
  def fiscal_id_description(code)
    _m = '$err'
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

  # IS NUMERIC
  def is_numeric?(object)
    true if Float(object) rescue false
  end  

  #
  # Automatic codes & document numbers
  #
  # Supplier code
  def su_next_code(organization, activity)
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    activity = activity.split(",").first
    activity = activity.rjust(4, '0')
    last_code = Supplier.where("supplier_code LIKE ?", "#{organization}#{activity}%").order(:supplier_code).maximum(:supplier_code)
    if last_code.nil?
      code = organization + activity + '000001'
    else
      last_code = last_code[8..13].to_i + 1
      code = organization + activity + last_code.to_s.rjust(6, '0')
    end
    code
  end

  # Client code
  def cl_next_code(organization)
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    last_code = Client.where("client_code LIKE ?", "#{organization}%").order(:client_code).maximum(:client_code)
    if last_code.nil?
      code = organization + '0000001'
    else
      last_code = last_code[4..10].to_i + 1
      code = organization + last_code.to_s.rjust(7, '0')
    end
    code
  end

  # Product code
  def pt_next_code(organization, family)
    code = ''
    # Builds code, if possible
    family_code = ProductFamily.find(family).family_code rescue '$'
    if family_code == '$'
      code = '$err'
    else
      family = family_code.rjust(4, '0')
      if organization == 0
        last_code = Product.where("product_code LIKE ?", "#{family}%").order(:product_code).maximum(:product_code)
      else
        last_code = Product.where("product_code LIKE ? AND organization_id = ?", "#{family}%", "#{organization}").order(:product_code).maximum(:product_code)
      end
      if last_code.nil?
        code = family + '000001'
      else
        last_code = last_code[4..9].to_i + 1
        code = family + last_code.to_s.rjust(6, '0')
      end
    end
    code
  end
  
  # Project code
  def pr_next_code(company, type)
    code = ''
    # Builds code, if possible
    type_code = ProjectType.find(type).code rescue '$'
    if type_code == '$'
      code = '$err'
    else
      type = type_code[0,3].upcase
      company = company.to_s if company.is_a? Fixnum
      company = company.rjust(3, '0')
      last_code = Project.where("project_code LIKE ?", "#{company}#{type}%").order(:project_code).maximum(:project_code)
      if last_code.nil?
        code = company + type + '000001'
      else
        last_code = last_code[6..11].to_i + 1
        code = company + type + last_code.to_s.rjust(6, '0')
      end
    end
    code
  end

  # Charge account code
  def cc_next_code(organization, group)
    code = ''
    # Builds code, if possible
    group_code = ChargeGroup.find(group).group_code rescue '$'
    if group_code == '$'
      code = '$err'
    else
      group = group_code.rjust(4, '0')
      if organization == 0
        last_code = ChargeAccount.where("account_code LIKE ?", "#{group}%").order(:account_code).maximum(:account_code)
      else
        last_code = ChargeAccount.where("account_code LIKE ? AND organization_id = ?", "#{group}%", "#{organization}").order(:account_code).maximum(:account_code)
      end
      if last_code.nil?
        code = group + '0000001'
      else
        last_code = last_code[4..10].to_i + 1
        code = group + last_code.to_s.rjust(7, '0')
      end
    end
    code
   end
  
  # Budget no
  def bu_next_no(project, period)
    code = ''
    # Builds code, if possible
    project_code = Project.find(project).project_code rescue '$'
    period_code = BudgetPeriod.find(period).period_code rescue '$'
    if project_code == '$' || period_code == '$'
      code = '$err'
    else
      project = project_code[0,12].upcase.rjust(12, '0')
      period = period_code[0,8].upcase.rjust(8, '0')
      last_no = Budget.where("buget_no LIKE ?", "#{project}#{period}")
      if !last_no.nil?
        code = project + period
      else
        code = '$err'
      end
    end
    code
  end
  
  # Delivery note no
  def dn_next_no(organization)
    year = Time.new.year
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = DeliveryNote.where("delivery_no LIKE ?", "#{organization}#{year}%").order(:delivery_no).maximum(:delivery_no)
    if last_no.nil?
      code = organization + year + '000001'
    else
      last_no = last_no[14..19].to_i + 1
      code = organization + year + last_no.to_s.rjust(6, '0')
    end
    code
  end
  
  # Purchase order no
  def po_next_no(project)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    project_code = Project.find(project).project_code rescue '$'
    if project_code == '$'
      code = '$err'
    else
      project = project_code.rjust(12, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = PurchaseOrder.where("order_no LIKE ?", "#{project}#{year}%").order(:order_no).maximum(:order_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end
  
  # Work order no
  def wo_next_no(project)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    project_code = Project.find(project).project_code rescue '$'
    if project_code == '$'
      code = '$err'
    else
      project = project_code.rjust(12, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = WorkOrder.where("order_no LIKE ?", "#{project}#{year}%").order(:order_no).maximum(:order_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end
  
  # Offer request no
  def or_next_no(project)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    project_code = Project.find(project).project_code rescue '$'
    if project_code == '$'
      code = '$err'
    else
      project = project_code.rjust(12, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = OfferRequest.where("request_no LIKE ?", "#{project}#{year}%").order(:request_no).maximum(:request_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

  # Ratio code
  def ra_next_code(organization, group)
    code = ''
    # Builds code, if possible
    group_code = RatioGroup.find(group).code rescue '$'
    if group_code == '$'
      code = '$err'
    else
      group = group_code.rjust(4, '0')
      if organization == 0
        last_code = Ratio.where("code LIKE ?", "#{group}%").order(:code).maximum(:code)
      else
        last_code = Ratio.where("code LIKE ? AND organization_id = ?", "#{group}%", "#{organization}").order(:code).maximum(:code)
      end
      if last_code.nil?
        code = group + '0000001'
      else
        last_code = last_code[4..10].to_i + 1
        code = group + last_code.to_s.rjust(7, '0')
      end
    end
    code
  end

  #
  # Privates
  #
  private
  
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
    elsif is_a?(GuideController)
      "guide"
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
