class ChangeHoursInCagreements < ActiveRecord::Migration
  def change
    change_column :collective_agreements, :hours, :integer, :limit => 2, :default => '0'
  end
end
