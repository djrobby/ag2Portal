class AddRegionIdToProvinces < ActiveRecord::Migration
  def change
    add_column :provinces, :region_id, :integer
  end
end
