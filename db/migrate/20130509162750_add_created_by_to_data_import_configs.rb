class AddCreatedByToDataImportConfigs < ActiveRecord::Migration
  def change
    add_column :data_import_configs, :created_by, :integer
    add_column :data_import_configs, :updated_by, :integer
  end
end
