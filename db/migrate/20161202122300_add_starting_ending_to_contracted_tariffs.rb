class AddStartingEndingToContractedTariffs < ActiveRecord::Migration
  def change
    add_column :contracted_tariffs, :starting_at, :date
    add_column :contracted_tariffs, :ending_at, :date

    add_index :contracted_tariffs, :starting_at
    add_index :contracted_tariffs, :ending_at
  end
end
