class AddRepresentativePositionToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :r_position, :string
  end
end
