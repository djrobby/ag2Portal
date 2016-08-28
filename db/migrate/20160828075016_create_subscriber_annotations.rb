class CreateSubscriberAnnotations < ActiveRecord::Migration
  def change
    create_table :subscriber_annotations do |t|
      t.references :subscriber
      t.references :subscriber_annotation
      t.string :annotation

      t.timestamps
    end
    add_index :subscriber_annotations, :subscriber_id
    add_index :subscriber_annotations, :subscriber_annotation_id
    add_index :subscriber_annotations, :created_at
  end
end
