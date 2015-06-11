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

    mail from: user.email, to: "helpdesk@aguaygestion.com"
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
      mail from: user.email, to: recipients
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
    _table = _ivar.class.table_name
    _project = _ivar.project rescue nil
    _office = _project.office rescue nil
    _company = _project.company rescue nil
    # First notification for the searched table & action
    _notification = Notification.where(table: _table, action: _action).first rescue nil
    # Only if notification
    if !_notification.blank?
      # By company
      _by_company = company_notification_recipients(_company, _notification, _role)
      # By office
      _by_office = office_notification_recipients(_office, _notification, _role)
      # Setup recipients
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
