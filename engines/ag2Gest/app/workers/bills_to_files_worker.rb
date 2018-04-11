class BillsToFilesWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def expiration
    @expiration ||= 60*60*24*30 # 30 days
  end

  def perform(bills)
    # do something
  end
end
