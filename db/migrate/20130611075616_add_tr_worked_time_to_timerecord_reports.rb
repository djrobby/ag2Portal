class AddTrWorkedTimeToTimerecordReports < ActiveRecord::Migration
  def change
    add_column :timerecord_reports, :tr_worked_time, :time
  end
end
