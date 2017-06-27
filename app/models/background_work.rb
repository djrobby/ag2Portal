class BackgroundWork < ActiveRecord::Base
  attr_accessible :failure, :group_no, :status, :total, :type_work, :user_id, :work_no,
                  :complete, :consumption, :price_total, :total_confirmed, :invoice_date,
                  :payday_limit, :first_bill, :last_bill
end
