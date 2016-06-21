class CreateServicePointTypes < ActiveRecord::Migration
  def change
    create_table :service_point_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
