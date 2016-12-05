class ChangeTypeInSubscriberAnnotationClasses < ActiveRecord::Migration
  def change
    remove_index :subscriber_annotation_classes, :type
    remove_column :subscriber_annotation_classes, :type

    add_column :subscriber_annotation_classes, :class_type, :integer, limit: 1, null: false, default: '1'
    add_index :subscriber_annotation_classes, :class_type
  end
end
