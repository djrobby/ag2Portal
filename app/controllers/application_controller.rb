class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  include ActionView::Helpers::NumberHelper

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
  helper_method :organizations_according_oco
  helper_method :formatted_date
  helper_method :formatted_timestamp
  helper_method :formatted_time
  helper_method :users_according_oco

  #
  # Formatting
  #
  def formatted_date(_date)
    _format = I18n.locale == :es ? "%d/%m/%Y" : "%m-%d-%Y"
    _date.strftime(_format)
  end
  def formatted_date_slash(_date)
    _format = I18n.locale == :es ? "%d/%m/%Y" : "%m/%d/%Y"
    _date.strftime(_format)
  end
  def formatted_timestamp(_date)
    _format = I18n.locale == :es ? "%d/%m/%Y %H:%M:%S" : "%m-%d-%Y %H:%M:%S"
    _date.strftime(_format)
  end
  def formatted_time(_date)
    _format = I18n.locale == :es ? "%H:%M:%S" : "%H:%M:%S"
    _date.strftime(_format)
  end
  def formatted_number(_number, _decimals)
    _delimiter = I18n.locale == :es ? "." : ","
    number_with_precision(_number.round(_decimals), precision: _decimals, delimiter: _delimiter)
  end
  def formatted_number_without_delimiter(_number, _decimals)
    number_with_precision(_number.round(_decimals), precision: _decimals)
  end
  def en_formatted_number_without_delimiter(_number, _decimals)
    number_with_precision(_number.round(_decimals), precision: _decimals, locale: :en)
  end

  #
  # OCO
  #
  def init_oco
    session[:administrator] = false

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

      # Administrator?
      session[:is_administrator] = current_user.has_role? :Administrator
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

  def organizations_according_oco
    if session[:organization] != '0'
      _org = Organization.where("id = ?", "#{session[:organization]}").all
      _include_blank = false
    elsif current_user.organizations.count > 0
      _org = current_user.organizations.order('name')
      _include_blank = false
    else
      _org = Organization.order('name')
      _include_blank = true
    end
    return _org, _include_blank
  end

  def users_according_oco
    (session[:organization] && (session[:organization] != '0' && session[:organization] != 0)) ? Organization.find(session[:organization].to_i).users.by_email : User.by_email
  end

  #
  # Approvers
  #
  def company_approver(ivar, company, current_user_id)
    table = ivar.class.table_name
    notifications = company.company_notifications.joins(:notification).where('notifications.table = ? AND company_notifications.role = ? AND company_notifications.user_id = ?', table, 1, current_user_id) rescue nil
    !notifications.blank?
  end

  def office_approver(ivar, office, current_user_id)
    table = ivar.class.table_name
    notifications = office.office_notifications.joins(:notification).where('notifications.table = ? AND office_notifications.role = ? AND office_notifications.user_id = ?', table, 1, current_user_id) rescue nil
    !notifications.blank?
  end

  def zone_approver(ivar, zone, current_user_id)
    table = ivar.class.table_name
    notifications = zone.zone_notifications.joins(:notification).where('notifications.table = ? AND zone_notifications.role = ? AND zone_notifications.user_id = ?', table, 1, current_user_id) rescue nil
    !notifications.blank?
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
        elsif fiscal_id[0] == 'X' || fiscal_id[0] == 'Y' || fiscal_id[0] == 'Z'
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

  #
  # Bank, IBAN & SEPA generic methods
  #
  # Check IBAN
  # Returns formatted IBAN
  def check_iban(country, dc, bank, office, account)
    _country = nil
    _bank = nil
    _office = nil
    _iban = ''

    if country != '0'
      _country = Country.find(country)
      _iban += _country.blank? ? 'ES' : _country.code
    end
    _iban += dc != '0' ? dc : '00'
    if bank != '0'
      _bank = Bank.find(bank)
      _iban += _bank.blank? ? '0000' : _bank.code
    end
    if office != '0'
      _office = BankOffice.find(office)
      _iban += _office.blank? ? '0000' : _office.code
    end
    _iban += account != '0' ? account : '0000000000'
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
  def cc_next_code(organization, group, project)
    code = ''
    # Builds code, if possible
    group_code = ChargeGroup.find(group).group_code rescue '$'
    if group_code == '$'
      code = '$err'
    else
      group = group_code.rjust(4, '0')
      project = project.rjust(4, '0')
      if organization == 0
        if project == '0000'
          last_code = ChargeAccount.where("account_code LIKE ? AND (project_id = ? OR project_id IS NULL)", "#{group}%", "#{project}").order(:account_code).maximum(:account_code)
        else
          last_code = ChargeAccount.where("account_code LIKE ? AND project_id = ?", "#{group}%", "#{project}").order(:account_code).maximum(:account_code)
        end
      else
        if project == '0000'
          last_code = ChargeAccount.where("account_code LIKE ? AND (project_id = ? OR project_id IS NULL) AND organization_id = ?", "#{group}%", "#{project}", "#{organization}").order(:account_code).maximum(:account_code)
        else
          last_code = ChargeAccount.where("account_code LIKE ? AND project_id = ? AND organization_id = ?", "#{group}%", "#{project}", "#{organization}").order(:account_code).maximum(:account_code)
        end
      end
      code = group + project
      if last_code.nil?
        code += '01'
      else
        last_code = last_code[8..9].to_i + 1
        code += last_code.to_s.rjust(2, '0')
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
      last_no = Budget.where("budget_no = ?", "#{project}#{period}")
      if last_no.blank?
        code = project + period
      else
        code = '$err'
      end
    end
    code
  end

  # Delivery note no
  def dn_next_no(project)
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
      last_no = DeliveryNote.where("delivery_no LIKE ?", "#{project}#{year}%").order(:delivery_no).maximum(:delivery_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
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

  # Inventory count no
  def ic_next_no(store)
    year = Time.new.year
    code = ''
    store = store.to_s if store.is_a? Fixnum
    store = store.rjust(4, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = InventoryCount.where("count_no LIKE ?", "#{store}#{year}%").order(:count_no).maximum(:count_no)
    if last_no.nil?
      code = store + year + '000001'
    else
      last_no = last_no[8..13].to_i + 1
      code = store + year + last_no.to_s.rjust(6, '0')
    end
    code
  end

  # Inventory transfer no
  def it_next_no(store)
    year = Time.new.year
    code = ''
    store = store.to_s if store.is_a? Fixnum
    store = store.rjust(4, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = InventoryTransfer.where("count_no LIKE ?", "#{store}#{year}%").order(:count_no).maximum(:count_no)
    if last_no.nil?
      code = store + year + '000001'
    else
      last_no = last_no[8..13].to_i + 1
      code = store + year + last_no.to_s.rjust(6, '0')
    end
    code
  end

  # Supplier invoice internal no
  def si_next_no(company, posted_at)
    code = ''
    year = posted_at.year
    company = company.to_s if company.is_a? Fixnum
    company = company.rjust(3, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = SupplierInvoice.where("internal_no LIKE ?", "#{company}#{year}%").order(:internal_no).maximum(:internal_no)
    if last_no.nil?
      code = company + year + '000001'
    else
      last_no = last_no[7..12].to_i + 1
      code = company + year + last_no.to_s.rjust(6, '0')
    end
    code
  end

  # Supplier payment no
  def sp_next_no(organization)
    year = Time.new.year
    code = ''
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(4, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = SupplierPayment.where("payment_no LIKE ?", "#{organization}#{year}%").order(:payment_no).maximum(:payment_no)
    if last_no.nil?
      code = organization + year + '000001'
    else
      last_no = last_no[8..13].to_i + 1
      code = organization + year + last_no.to_s.rjust(6, '0')
    end
    code
  end

  # Infrastructure code
  def in_next_code(organization, type)
    code = ''
    # Builds code, if possible
    organization = organization.to_s if organization.is_a? Fixnum
    organization = organization.rjust(3, '0')
    type = type.to_s if type.is_a? Fixnum
    type = type.rjust(3, '0')
    last_code = Infrastructure.where("code LIKE ?", "#{organization}#{type}%").order(:code).maximum(:code)
    if last_code.nil?
      code = organization + type + '000001'
    else
      last_code = last_code[6..11].to_i + 1
      code = organization + type + last_code.to_s.rjust(6, '0')
    end
    code
  end

  # Contracting request no
  def cr_next_no(project)
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
      last_no = ContractingRequest.where("request_no LIKE ?", "#{project}#{year}%").order(:request_no).maximum(:request_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

  # Contract no (for WaterSupplyContract & WaterConnectionContract)
  # Params: project_id, type_id
  def contract_next_no(project, type)
    year = Time.new.year
    last_no = nil
    code = ''
    # Builds code, if possible
    project = project.to_s if project.is_a? Fixnum
    project = project.rjust(6, '0')
    type_s = type.to_s if type.is_a? Fixnum
    type_s = type_s.rjust(2, '0')
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    if type == ContractingRequestType::CONNECTION
      last_no = WaterConnectionContract.where("contract_no LIKE ?", "#{project}#{type_s}#{year}%").order(:contract_no).maximum(:contract_no)
    else
      last_no = WaterSupplyContract.where("contract_no LIKE ?", "#{project}#{type_s}#{year}%").order(:contract_no).maximum(:contract_no)
    end
    if last_no.nil?
      code = project + type_s + year + '000001'
    else
      last_no = last_no[12..17].to_i + 1
      code = project + type_s + year + last_no.to_s.rjust(6, '0')
    end
    code
  end

  # Bill no
  def bill_next_no(project)
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
      last_no = Bill.where("bill_no LIKE ?", "#{project}#{year}%").order(:bill_no).maximum(:bill_no)
      if last_no.nil?
        code = project + year + '0000001'
      else
        last_no = last_no[16..22].to_i + 1
        code = project + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

  # Invoice no
  def invoice_next_no(company, office = nil)
    year = Time.new.year
    code = ''
    serial = ''
    office_code = office.nil? ? '00' : office.to_s.rjust(2, '0')
    # Builds code, if possible
    company_code = Company.find(company).invoice_code rescue '$'
    if company_code == '$'
      code = '$err'
    else
      serial = company_code.rjust(3, '0') + office_code
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = Invoice.where("invoice_no LIKE ?", "#{serial}#{year}%").order(:invoice_no).maximum(:invoice_no)
      if last_no.nil?
        code = serial + year + '0000001'
      else
        last_no = last_no[9..15].to_i + 1
        code = serial + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

  # Void Invoice no
  def void_invoice_next_no(company, office = nil)
    year = Time.new.year
    code = ''
    serial = ''
    office_code = office.nil? ? '00' : office.to_s.rjust(2, '0')
    # Builds code, if possible
    company_code = Company.find(company).void_invoice_code rescue '$'
    if company_code == '$'
      code = '$err'
    else
      serial = company_code.rjust(3, '0') + office_code
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = Invoice.where("invoice_no LIKE ?", "#{serial}#{year}%").order(:invoice_no).maximum(:invoice_no)
      if last_no.nil?
        code = serial + year + '0000001'
      else
        last_no = last_no[9..15].to_i + 1
        code = serial + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

  # Commercial bill no
  # serial length must be 5 and code must returns 15 chars
  def commercial_bill_next_no(company, office = nil)
    year = Time.new.year
    code = ''
    serial = ''
    office_code = office.nil? ? '00' : office.to_s.rjust(2, '0')
    # Builds code, if possible
    company_code = Company.find(company).commercial_bill_code rescue '$'
    company_code = company_code.nil? ? '$' : company_code
    if company_code == '$'
      code = '$err'
    else
      serial = company_code.rjust(3, '0') + office_code
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = Invoice.where("invoice_no LIKE ?", "#{serial}#{year}%").order(:invoice_no).maximum(:invoice_no)
      if last_no.nil?
        code = serial + year + '0000001'
      else
        last_no = last_no[9..15].to_i + 1
        code = serial + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

  # Client payment's Receipt no
  def receipt_next_no(office = nil)
    year = Time.new.year
    code = ''
    office_code = office.nil? ? '0000' : office.to_s.rjust(4, '0')
    # Builds code, if possible
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = ClientPayment.where("receipt_no LIKE ?", "#{office_code}#{year}%").order(:receipt_no).maximum(:receipt_no)
    if last_no.nil?
      code = office_code + year + '00001'
    else
      last_no = last_no[8..12].to_i + 1
      code = office_code + year + last_no.to_s.rjust(5, '0')
    end
    code
  end

  # Sale offer no
  def sale_offer_next_no(project)
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
      last_no = SaleOffer.where("offer_no LIKE ?", "#{project}#{year}%").order(:offer_no).maximum(:offer_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

  # Subscriber code
  def sub_next_no(office)
    code = ''
    office = office.to_s if office.is_a? Fixnum
    office = office.rjust(4, '0')
    last_no = Subscriber.where("subscriber_code LIKE ?", "#{office}%").order(:subscriber_code).maximum(:subscriber_code)
    if last_no.nil?
      code = office + '0000001'
    else
      last_no = last_no[4..10].to_i + 1
      code = office +  last_no.to_s.rjust(7, '0')
    end
    code
  end

  # Service point code
  def serpoint_next_no(office)
    code = ''
    office = office.to_s if office.is_a? Fixnum
    office = office.rjust(4, '0')
    last_no = ServicePoint.where("code LIKE ?", "#{office}%").order(:code).maximum(:code)
    if last_no.nil?
      code = office + '0000001'
    else
      last_no = last_no[4..10].to_i + 1
      code = office +  last_no.to_s.rjust(7, '0')
    end
    code
  end

  # Instalment plan no
  def instalment_plan_next_no(client)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    client_code = Client.find(client).client_code rescue '$'
    if client_code == '$'
      code = '$err'
    else
      client = client_code.rjust(11, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = InstalmentPlan.where("instalment_no LIKE ?", "#{client}#{year}%").order(:instalment_no).maximum(:instalment_no)
      if last_no.nil?
        code = client + year + '0000001'
      else
        last_no = last_no[16..22].to_i + 1
        code = client + year + last_no.to_s.rjust(7, '0')
      end
    end
    code
  end

  # Debt claim no
  def dc_next_no(office)
    year = Time.new.year
    code = ''
    office_code = office.nil? ? '0000' : office.to_s.rjust(4, '0')
    # Builds code, if possible
    year = year.to_s if year.is_a? Fixnum
    year = year.rjust(4, '0')
    last_no = DebtClaim.where("claim_no LIKE ?", "#{office_code}#{year}%").order(:claim_no).maximum(:claim_no)
    if last_no.nil?
      code = office_code + year + '00001'
    else
      last_no = last_no[8..12].to_i + 1
      code = office_code + year + last_no.to_s.rjust(5, '0')
    end
    code
  end

  #
  # For readings
  #
  def set_reading_1_to_reading(subscriber,meter,billing_period)
    # reading = meter.readings.where(reading_type_id: ReadingType::INSTALACION, billing_period_id: billing_period.id ,subscriber_id: subscriber.id).order(:reading_date).last
    r = nil
    reading = meter.readings.where(reading_type_id: ReadingType::INSTALACION, billing_period_id: billing_period.id ,subscriber_id: subscriber.nil? ? nil : subscriber.id).order(:reading_date).last
    if !reading.blank?
      r = reading
    else
      previous_year_period_id = BillingPeriod.find_by_period_and_billing_frequency_id(billing_period.previous_period,billing_period.billing_frequency_id).try(:id)
      if !previous_year_period_id.blank?
        # Reading.where(meter_id: meter.id, reading_type_id: [ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO], billing_period_id: previous_year_period_id, subscriber_id: subscriber.id).order(:reading_date).last || Reading.where(meter_id: meter.id, reading_type_id: ReadingType::INSTALACION, billing_period_id: previous_year_period_id).order(:reading_date).last
        r = Reading.where(meter_id: meter.id, reading_type_id: [ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO], billing_period_id: previous_year_period_id, subscriber_id: subscriber.nil? ? nil : subscriber.id).order(:reading_date).last || Reading.where(meter_id: meter.id, reading_type_id: ReadingType::INSTALACION, billing_period_id: previous_year_period_id).order(:reading_date).last
      end
    end
    r
  end

  def set_reading_2_to_reading(subscriber,meter,billing_period)
    r = nil
    previous_year_period_id = BillingPeriod.find_by_period_and_billing_frequency_id(billing_period.year_period,billing_period.billing_frequency_id).try(:id)
    if !previous_year_period_id.blank?
      r = Reading.where(meter_id: meter.id, reading_type_id: [ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::INSTALACION,ReadingType::RETIRADA,ReadingType::AUTO], billing_period_id: previous_year_period_id, subscriber_id: subscriber.nil? ? nil : subscriber.id).order(:reading_date).last
    end
    r
  end

  #
  # File operations
  #
  # Upload XML file to Rails server (public/uploads)
  def upload_xml_file(file_name, xml)
    # Creates directory if it doesn't exist
    create_upload_dir
    # Save file to server's uploads dir
    file_to_upload = File.open(Rails.root.join('public', 'uploads', file_name), "wb")
    file_to_upload.write(xml)
    file_to_upload.close()
  end

  def create_upload_dir
    dir = Rails.root.join('public', 'uploads')
    Dir.mkdir(dir) unless File.exists?(dir)
  end

  # Save local file
  def save_local_file(file_name, xml)
    file_to_upload = File.open(file_name, "w")
    file_to_upload.write(xml)
    file_to_upload.close()
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
    begin
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    rescue
      'es'
    end
    #request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
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
    elsif is_a?(ErrorsController)
      "errors"
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

  def background_job_status
    remote_url = ''
    if !current_user.blank?
      if current_user.creating_prebills?
        remote_url = '/ag2_gest/es/bills/status_prebills'
      end
      if current_user.confirming_prebills?
        remote_url = '/ag2_gest/es/bills/status_confirm'
      end
      if current_user.confirming_prereadings?
        remote_url = '/ag2_gest/es/pre_readings/status_confirm'
      end
    end
    return remote_url
  end
end
