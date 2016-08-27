class AddCreatedByToClientPayments < ActiveRecord::Migration
  def change
    add_column :client_payments, :created_by, :integer
    add_column :client_payments, :updated_by, :integer
  end
end
