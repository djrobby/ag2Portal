class CreateRegulationTypes < ActiveRecord::Migration
  def change
    create_table :regulation_types do |t|
      t.string :description

      t.timestamps
    end
  end
end
