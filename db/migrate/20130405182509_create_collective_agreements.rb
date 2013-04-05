class CreateCollectiveAgreements < ActiveRecord::Migration
  def change
    create_table :collective_agreements do |t|
      t.string :name
      t.string :ca_code

      t.timestamps
    end
    add_index :collective_agreements, :ca_code
  end
end
