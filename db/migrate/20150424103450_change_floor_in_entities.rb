class ChangeFloorInEntities < ActiveRecord::Migration
  def change
    change_column :entities, :floor, :string
  end
end
