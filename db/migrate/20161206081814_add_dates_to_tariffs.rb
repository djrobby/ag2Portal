class AddDatesToTariffs < ActiveRecord::Migration
  def change
    add_column :tariffs, :starting_at, :date
    add_column :tariffs, :ending_at, :date
  end
end
