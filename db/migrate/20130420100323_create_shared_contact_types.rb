class CreateSharedContactTypes < ActiveRecord::Migration
  def change
    create_table :shared_contact_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
