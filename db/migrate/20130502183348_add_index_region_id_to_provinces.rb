class AddIndexRegionIdToProvinces < ActiveRecord::Migration
  def change
    add_index :provinces, :region_id
  end
end
