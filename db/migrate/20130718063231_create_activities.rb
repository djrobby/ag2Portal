class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :description

      t.timestamps
    end
    add_index :activities, :description
  end
end
