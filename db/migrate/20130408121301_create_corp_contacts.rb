class CreateCorpContacts < ActiveRecord::Migration
  def change
    create_table :corp_contacts do |t|
      t.string :first_name
      t.string :last_name
      t.references :company
      t.references :office
      t.references :department
      t.string :position
      t.string :email
      t.string :corp_phone
      t.string :corp_extension
      t.string :corp_cellular_long
      t.string :corp_cellular_short

      t.timestamps
    end
    add_index :corp_contacts, :company_id
    add_index :corp_contacts, :office_id
    add_index :corp_contacts, :department_id
    add_index :corp_contacts, :first_name
    add_index :corp_contacts, :last_name
    add_index :corp_contacts, :email
    add_index :corp_contacts, :corp_phone
    add_index :corp_contacts, :corp_extension
    add_index :corp_contacts, :corp_cellular_long
    add_index :corp_contacts, :corp_cellular_short
  end
end
