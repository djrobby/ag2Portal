class FixColumnNamePhoneAtWorkers < ActiveRecord::Migration
  def change
    rename_column :workers, :phone, :own_phone
    rename_column :workers, :cellular, :own_cellular
  end
end
