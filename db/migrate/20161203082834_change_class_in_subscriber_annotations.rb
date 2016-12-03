class ChangeClassInSubscriberAnnotations < ActiveRecord::Migration
  def change
    remove_index :subscriber_annotations, :subscriber_annotation_id
    remove_column :subscriber_annotations, :subscriber_annotation_id

    add_column :subscriber_annotations, :subscriber_annotation_class_id, :integer
    add_index :subscriber_annotations, :subscriber_annotation_class_id
  end
end
