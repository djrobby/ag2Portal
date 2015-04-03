class ChangeFloorInOffices < ActiveRecord::Migration
  def change
    change_column :offices, :floor, :string
  end
end
