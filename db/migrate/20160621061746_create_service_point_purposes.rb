class CreateServicePointPurposes < ActiveRecord::Migration
  def change
    create_table :service_point_purposes do |t|
      t.string :name

      t.timestamps
    end
  end
end
