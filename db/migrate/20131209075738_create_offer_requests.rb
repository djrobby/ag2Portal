class CreateOfferRequests < ActiveRecord::Migration
  def change
    create_table :offer_requests do |t|
      t.string :request_no
      t.date :request_date
      t.date :deadline_date
      t.references :payment_method
      t.references :project
      t.references :approved_offer
      t.timestamp :approval_date
      t.references :approver

      t.timestamps
    end
    add_index :offer_requests, :payment_method_id
    add_index :offer_requests, :project_id
    add_index :offer_requests, :approved_offer_id
    add_index :offer_requests, :approver_id
    add_index :offer_requests, :request_no
    add_index :offer_requests, :request_date
  end
end
