class BankToOrderWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def expiration
    @expiration ||= 60*60*24*30 # 30 days
  end

  def perform(client_payments_ids, bank_account_id, scheme_type_id, presentation_date, charge_date)
    # do something
  end
end
