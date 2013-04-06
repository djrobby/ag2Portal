class CreateWorkerTypes < ActiveRecord::Migration
  def change
    create_table :worker_types do |t|
      t.string :description

      t.timestamps
    end
  end
end
