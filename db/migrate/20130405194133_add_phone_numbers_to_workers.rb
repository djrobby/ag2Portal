class AddPhoneNumbersToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :corp_phone, :string
    add_column :workers, :corp_cellular_long, :string
    add_column :workers, :corp_cellular_short, :string

    add_index :workers, :corp_phone
    add_index :workers, :corp_cellular_long
    add_index :workers, :corp_cellular_short
  end
end
