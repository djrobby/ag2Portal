class AddIndexDescriptionToMeasures < ActiveRecord::Migration
  def change
    add_index :measures, :description
  end
end
