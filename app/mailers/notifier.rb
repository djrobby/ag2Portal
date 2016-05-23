class Notifier < ActionMailer::Base
  helper NotifierHelper

  default from: "agestiona2@aguaygestion.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup (example):
  #
  #   en.notifier.user_created.subject
  #
  # User
  def user_created(user)
    @user = user

    mail reply_to: user.email, to: "helpdesk@aguaygestion.com"
  end

  # Ticket
  def ticket_created(ticket)
    @ticket = ticket

    user = User.find(ticket.created_by) rescue nil
    cc = User.find(ticket.cc_id) rescue nil
    recipients = ticket.hd_email
    if !user.nil?
      if !cc.nil?
        recipients += "," + cc.email
      end
      mail reply_to: user.email, to: recipients
    end
  end

  def ticket_updated(ticket)
    @ticket = ticket

    user = User.find(ticket.created_by) rescue nil
    cc = User.find(ticket.cc_id) rescue nil
    if !user.nil?
      recipients = user.email
      if !cc.nil?
        recipients += "," + cc.email
      end
      mail to: recipients
    end
  end

  def ticket_assigned(ticket)
    @ticket = ticket
    @current_host = current_host
    mail to: ticket.technician.user.email do |format|
      format.html
    end
  end

  # Purchase order
  def purchase_order_saved(purchase_order, action)
    @purchase_order = purchase_order
    @current_host = current_host
    recipients = notify_to(purchase_order, action, 2)
    #recipients = "spsisys@gmail.com"
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def purchase_order_saved_with_approval(purchase_order, action)
    @purchase_order = purchase_order
    @current_host = current_host
    recipients = notify_to(purchase_order, action, 1)
    #recipients = "spsisys@gmail.com"
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def send_purchase_order(purchase_order, _from, _to, title, pdf)
    @purchase_order = purchase_order
    @from = _from
    _subject = t("notifier.send_purchase_order.subject") + @purchase_order.project.company.name
    attachments[title] = pdf
    mail reply_to: _from, to: _to, bcc: _from, subject: _subject
  end

  def send_purchase_order_approval(purchase_order, _from, _to)
    @purchase_order = purchase_order
    @current_host = current_host
    d = purchase_order.approval_date.utc
    t = Time.new(d.year, d.month, d.day, d.hour, d.min, d.sec, d.zone)
    @approved_at = t.getlocal
    mail reply_to: _from, to: _to do |format|
      format.html
    end
  end

  def send_purchase_order_notification(purchase_order, _from, _to)
    @purchase_order = purchase_order
    @current_host = current_host
    #d = purchase_order.approval_date.utc
    #t = Time.new(d.year, d.month, d.day, d.hour, d.min, d.sec, d.zone)
    @approved_at = purchase_order.approval_date.utc.getlocal
    @from = _from
    mail reply_to: _from, to: _to do |format|
      format.html
    end
  end

  # Offer & Offer request
  def offer_saved(offer, action)
    @offer = offer
    @current_host = current_host
    recipients = notify_to(offer, action, 2)
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def offer_saved_with_approval(offer, action)
    @offer = offer
    @current_host = current_host
    recipients = notify_to(offer, action, 1)
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def send_offer_approval(offer, _from, _to)
    @offer = offer
    @current_host = current_host
    d = offer.approval_date.utc
    t = Time.new(d.year, d.month, d.day, d.hour, d.min, d.sec, d.zone)
    @approved_at = t.getlocal
    mail reply_to: _from, to: _to do |format|
      format.html
    end
  end

  def send_offer_request(offer_request, _from, _to, title, pdf)
    @offer_request = offer_request
    @from = _from
    _subject = t("notifier.send_offer_request.subject") + @offer_request.project.company.name
    attachments[title] = pdf
    mail reply_to: _from, to: _to, bcc: _from, subject: _subject
  end

  # Inventory count
  def inventory_count_saved(inventory_count, action)
    @inventory_count = inventory_count
    @current_host = current_host
    recipients = notify_to(inventory_count, action, 2)
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def inventory_count_saved_with_approval(inventory_count, action)
    @inventory_count = inventory_count
    @current_host = current_host
    recipients = notify_to(inventory_count, action, 1)
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def send_inventory_count_approval(inventory_count, _from, _to)
    @inventory_count = inventory_count
    @current_host = current_host
    d = inventory_count.approval_date.utc
    t = Time.new(d.year, d.month, d.day, d.hour, d.min, d.sec, d.zone)
    @approved_at = t.getlocal
    mail reply_to: _from, to: _to do |format|
      format.html
    end
  end

  # Supplier invoice & Payment
  def supplier_invoice_saved(supplier_invoice, action)
    @supplier_invoice = supplier_invoice
    @current_host = current_host
    recipients = notify_to(supplier_invoice, action, 2)
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  def supplier_invoice_saved_with_approval(supplier_invoice, action)
    @supplier_invoice = supplier_invoice
    @current_host = current_host
    recipients = notify_to(supplier_invoice, action, 1)
    if recipients != ''
      mail to: recipients do |format|
        format.html
      end
    end
  end

  #
  # Recipients based on Notifications
  # action: 1=Create 2=Update 3=Delete
  # role: 1=Approve 2=Notify
  #
  # Notification recipients
  def notify_to(_ivar, _action, _role)
    _recipients = ''
    _by_company = nil
    _by_office = nil
    _by_zone = nil
    _table = _ivar.class.table_name
    _project = _ivar.project rescue nil
    _store = _ivar.store rescue nil
    _office = nil
    _company = nil
    _zone = nil
    # Search office & company
    if !_project.blank?
      # From project
      _office = _project.office rescue nil
      _company = _project.company rescue nil
      _zone = _project.office.zone rescue nil
    elsif !_store.blank?
      # From store
      _office = _store.office rescue nil
      _company = _store.company rescue nil
      _zone = _store.office.zone rescue nil
    end
    # First notification for the searched table & action
    _notification = Notification.where(table: _table, action: _action).first rescue nil
    # Only if notification
    if !_notification.blank?
      # By company
      _by_company = company_notification_recipients(_company, _notification, _role)
      # By office
      _by_office = office_notification_recipients(_office, _notification, _role)
      # By zone
      _by_zone = zone_notification_recipients(_zone, _notification, _role)
      # Setup recipients
=begin
      if !_by_company.nil? && !_by_office.nil?
        _recipients = _by_company + "," + _by_office
      elsif !_by_company.nil? && _by_office.nil?
        _recipients = _by_company
      elsif _by_company.nil? && !_by_office.nil?
        _recipients = _by_office
      end
=end
      if !_by_company.nil?
        _recipients += _recipients.blank? ? _by_company : "," + _by_company
      end
      if !_by_office.nil?
        _recipients += _recipients.blank? ? _by_office : "," + _by_office
      end
      if !_by_zone.nil?
        _recipients += _recipients.blank? ? _by_zone : "," + _by_zone
      end

      if !_by_company.nil? && !_by_office.nil?
        _recipients = _by_company + "," + _by_office
      elsif !_by_company.nil? && _by_office.nil?
        _recipients = _by_company
      elsif _by_company.nil? && !_by_office.nil?
        _recipients = _by_office
      end
      #_recipients = (_by_company.nil? ? '' : _by_company) + (_by_office.nil? ? '' : _by_office)
    end
    _recipients
  end

  # Company notification recipients
  def company_notification_recipients(_company, _notification, _role)
    _recipients = nil
    if !_company.blank?
      _notifications = _company.company_notifications.where(notification_id: _notification.id, role: _role) rescue nil
      _recipients = recipients_string(_notifications)
    end
    _recipients
  end

  # Office notification recipients
  def office_notification_recipients(_office, _notification, _role)
    _recipients = nil
    if !_office.blank?
      _notifications = _office.office_notifications.where(notification_id: _notification.id, role: _role) rescue nil
      _recipients = recipients_string(_notifications)
    end
    _recipients
  end

  # Zone notification recipients
  def zone_notification_recipients(_zone, _notification, _role)
    _recipients = nil
    if !_zone.blank?
      _notifications = _zone.zone_notifications.where(notification_id: _notification.id, role: _role) rescue nil
      _recipients = recipients_string(_notifications)
    end
    _recipients
  end

  def recipients_string(_notifications)
    _recipients = nil
    if !_notifications.blank?
      _notifications.each do |n|
        if _recipients.nil?
          _recipients = n.user.email
        else
          _recipients += "," + n.user.email
        end
      end
    end
    _recipients
  end

  def current_host
    Rails.env.development? ? 'localhost:3000' : 'agestiona2.aguaygestion.com'
  end
end
