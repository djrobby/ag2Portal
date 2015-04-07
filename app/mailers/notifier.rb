class Notifier < ActionMailer::Base
  default from: "agestiona2@aguaygestion.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.user_created.subject
  #
  def user_created(user)
    @user = user

    mail from: user.email, to: "helpdesk@aguaygestion.com"
  end

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
end
