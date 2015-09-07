class ChangeIndexInBanks < ActiveRecord::Migration
  def change
    remove_index :banks, :code    

    add_index :banks, :code, unique: true
  end
end
