class AddExtensionToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :corp_extension, :string

    add_index :workers, :corp_extension
  end
end
