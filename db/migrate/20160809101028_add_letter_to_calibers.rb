class AddLetterToCalibers < ActiveRecord::Migration
  def change
    add_column :calibers, :letter_id, :string, :limit => 1
  end
end
