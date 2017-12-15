class CreateBillingIncidences < ActiveRecord::Migration
  def change
    create_table :billing_incidences do |t|
      t.references :bill
      t.references :invoice
      t.references :billing_incidence_type

      t.timestamps
    end
    add_index :billing_incidences, :bill_id
    add_index :billing_incidences, :invoice_id
    add_index :billing_incidences, :billing_incidence_type_id
  end
end
