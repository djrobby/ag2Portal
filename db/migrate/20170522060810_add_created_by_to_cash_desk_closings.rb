class AddCreatedByToCashDeskClosings < ActiveRecord::Migration
  def change
    add_column :cash_desk_closings, :created_by, :integer
    add_column :cash_desk_closings, :updated_by, :integer

    add_index :cash_desk_closings, :created_at
    add_index :cash_desk_closings, :created_by
  end
end
