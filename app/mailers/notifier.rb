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

    mail from: ticket.created_by, to: "helpdesk@aguaygestion.com"
  end
end
