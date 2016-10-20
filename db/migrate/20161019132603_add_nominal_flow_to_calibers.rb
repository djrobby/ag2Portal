class AddNominalFlowToCalibers < ActiveRecord::Migration
  def change
    add_column :calibers, :nominal_flow, :decimal, precision: 9, scale: 3, null: false, default: 0
  end
end
