class RemoveDiscountFromWorkerSalaries < ActiveRecord::Migration
  def change
    remove_column :worker_salaries, :discount_pct
  end
end
