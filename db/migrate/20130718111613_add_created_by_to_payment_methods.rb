class AddCreatedByToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :created_by, :string
    add_column :payment_methods, :updated_by, :string
  end
end
