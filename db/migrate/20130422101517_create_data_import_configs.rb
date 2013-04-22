class CreateDataImportConfigs < ActiveRecord::Migration
  def change
    create_table :data_import_configs do |t|
      t.string :name
      t.string :source
      t.string :target

      t.timestamps
    end
    add_index :data_import_configs, :name
  end
end
