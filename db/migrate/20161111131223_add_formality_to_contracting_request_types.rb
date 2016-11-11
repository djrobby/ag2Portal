class AddFormalityToContractingRequestTypes < ActiveRecord::Migration
  def change
    add_column :contracting_request_types, :formality_id, :integer
    add_index :contracting_request_types, :formality_id
  end
end
