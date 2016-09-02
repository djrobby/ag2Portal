class AddGisIdToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :gis_id_wc, :string
  end
end
