class AddHoursToCollectiveAgreements < ActiveRecord::Migration
  def change
    add_column :collective_agreements, :hours, :integer, :limit => 2
  end
end
