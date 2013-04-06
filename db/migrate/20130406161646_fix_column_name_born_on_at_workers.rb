class FixColumnNameBornOnAtWorkers < ActiveRecord::Migration
  def change
    rename_column :workers, :born_on, :borned_on
  end
end
