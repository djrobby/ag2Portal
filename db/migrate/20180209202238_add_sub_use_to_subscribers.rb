class AddSubUseToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :sub_use, :integer, limit: 2, null: false, default: 0
    add_column :subscribers, :pub_entity, :string
    add_column :subscribers, :landlord_tenant, :integer, limit: 2, null: false, default: 0

    add_index :subscribers, [:use_id, :sub_use]
    add_index :subscribers, :pub_entity
    add_index :subscribers, :landlord_tenant
  end
end
