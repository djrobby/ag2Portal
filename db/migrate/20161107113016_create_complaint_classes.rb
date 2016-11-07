class CreateComplaintClasses < ActiveRecord::Migration
  def change
    create_table :complaint_classes do |t|
      t.string :name

      t.timestamps
    end
    add_index :complaint_classes, :name
  end
end
