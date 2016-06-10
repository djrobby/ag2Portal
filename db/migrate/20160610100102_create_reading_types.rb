class CreateReadingTypes < ActiveRecord::Migration
  def change
    create_table :reading_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
