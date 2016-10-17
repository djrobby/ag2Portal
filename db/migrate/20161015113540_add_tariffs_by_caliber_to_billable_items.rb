class AddTariffsByCaliberToBillableItems < ActiveRecord::Migration
  def change
    add_column :billable_items, :tariffs_by_caliber, :boolean, default: false
  end
end
