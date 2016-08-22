class CreateContractingRequestStatuses < ActiveRecord::Migration
  def change
    create_table :contracting_request_statuses do |t|
      t.string :name
      t.boolean :requires_work_order

      t.timestamps
    end
  end
end
