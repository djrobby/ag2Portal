class AddCreatedByToProcessedFiles < ActiveRecord::Migration
  def change
    add_column :processed_files, :created_by, :integer
    add_column :processed_files, :updated_by, :integer
  end
end
