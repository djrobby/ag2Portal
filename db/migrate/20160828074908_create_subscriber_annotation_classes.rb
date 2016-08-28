class CreateSubscriberAnnotationClasses < ActiveRecord::Migration
  def change
    create_table :subscriber_annotation_classes do |t|
      t.string :code
      t.string :name
      t.integer :type, limit: 1, null: false, default: '1'

      t.timestamps
    end
    add_index :subscriber_annotation_classes, :code
    add_index :subscriber_annotation_classes, :type
  end
end
