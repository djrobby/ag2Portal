class CreateBudgetPeriods < ActiveRecord::Migration
  def change
    create_table :budget_periods do |t|
      t.string :period_code
      t.string :name
      t.timestamp :starting_at
      t.timestamp :ending_at
      t.references :organization

      t.timestamps
    end
    add_index :budget_periods, :organization_id    
    add_index :budget_periods, :period_code    
    add_index :budget_periods, :name    
    add_index :budget_periods, :starting_at    
    add_index :budget_periods, :ending_at    
    add_index :budget_periods, [:organization_id, :period_code], unique: true, name: 'index_budget_periods_on_organization_and_code'
  end
end
