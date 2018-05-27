class AddFileDateToProcessedFiles < ActiveRecord::Migration
  def change
    add_column :processed_files, :filedate, :date
  end
end
