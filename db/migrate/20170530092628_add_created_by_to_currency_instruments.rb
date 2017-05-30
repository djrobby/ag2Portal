class AddCreatedByToCurrencyInstruments < ActiveRecord::Migration
  def change
    add_column :currency_instruments, :created_by, :integer
    add_column :currency_instruments, :updated_by, :integer
  end
end
