class AddNafToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :born_on, :date
    add_column :workers, :issue_starting_at, :date
    add_column :workers, :affiliation_id, :string
    add_column :workers, :contribution_account_code, :string
    add_column :workers, :position, :string

    add_index :workers, :affiliation_id
    add_index :workers, :contribution_account_code
  end
end
