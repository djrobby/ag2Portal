class AddCodeToCenters < ActiveRecord::Migration
  def change
    add_column :centers, :code, :string

    add_index :centers, :code
    add_index :centers,
              [:town_id, :code],
              unique: true, name: 'index_centers_on_town_and_code'
  end
end
