class AddCreatedByToSubscriberAnnotationClasses < ActiveRecord::Migration
  def change
    add_column :subscriber_annotation_classes, :created_by, :integer
    add_column :subscriber_annotation_classes, :updated_by, :integer
  end
end
