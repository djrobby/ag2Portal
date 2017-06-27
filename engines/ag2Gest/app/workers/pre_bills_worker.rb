class PreBillsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def expiration
    @expiration ||= 60*60*24*30 # 30 days
  end

  def perform(readings_ids,group_no,user_id)
    bgw = BackgroundWork.find_by_work_no(self.jid)
    readings = Reading.where(id: readings_ids)
    @bills = []
    # (1..500).to_a.each do |t|
      # must be thread
      readings.each_with_index do |r,index|
        begin
          # raise "error" if (1..100).to_a.shuffle.first <= 10
          pre_bill = r.generate_pre_bill(group_no)
          if pre_bill.blank?
            bgw.update_attributes(failure: bgw.failure + "#{r.id}, ")
          else
            @bills << pre_bill
          end
        rescue
          bgw = BackgroundWork.find_by_work_no(self.jid)
          bgw.update_attributes(failure: bgw.failure + "#{r.id}, ")
          next
        end
      end
    # end
    bgw = BackgroundWork.find_by_work_no(self.jid)
    bgw.update_attributes(total: @bills.count)
  end

end
