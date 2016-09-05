class ChangeEndowmentsInSubscribers < ActiveRecord::Migration
  def change
    rename_column :subscribers, :endownments, :endowments
  end
end
