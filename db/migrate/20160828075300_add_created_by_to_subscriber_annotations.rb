class AddCreatedByToSubscriberAnnotations < ActiveRecord::Migration
  def change
    add_column :subscriber_annotations, :created_by, :integer
    add_column :subscriber_annotations, :updated_by, :integer

    add_index :subscriber_annotations, :created_by
  end
end
