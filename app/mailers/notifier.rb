class Notifier < ActionMailer::Base
  default from: "agestiona2@aguaygestion.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
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

  # Purchase order
  def purchase_order_saved(purchase_order)
    @purchase_order = purchase_order
    recipients = notify(purchase_order, 1, 2)
    if recipients != ''
      mail to: recipients
    end
  end

  def purchase_order_saved_with_approval(purchase_order)
    @purchase_order = purchase_order
    recipients = notify(purchase_order, 1, 1)
    if recipients != ''
      mail to: recipients
    end
  end
  
  #  
  # Recipients based on Notifications
  # action: 1=Create 2=Update 3=Delete
  # role: 1=Approve 2=Notify
  #  
  # Notification recipients
  def notify(_ivar, _action, _role)
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
      _recipients = (_by_company.nil? ? '' : _by_company) + (_by_office.nil? ? '' : _by_office)
    end
    _recipients
  end
  
  # Company notification recipients
  def company_notification_recipients(_company, _notification, _role)
    _recipients = nil
    if !_company.blank?
      _notifications = CompanyNotification.where(notification_id: _notification.id, role: _role) rescue nil
      _recipients = recipients_string(_notifications)
    end
    _recipients
  end
  
  # Office notification recipients
  def office_notification_recipients(_office, _notification, _role)
    _recipients = nil
    if !_office.blank?
      _notifications = OfficeNotification.where(notification_id: _notification.id, role: _role) rescue nil
      _recipients = recipients_string(_notifications)
    end
    _recipients
  end
  
  def recipients_string(_notifications)
    _recipients = nil
    if !_notifications.blank?
      _notifications.each do |n|
        if _recipients.nil?
          recipients += n.user.email
        else
          recipients += "," + n.user.email
        end
      end
    end
    _recipients
  end
end
