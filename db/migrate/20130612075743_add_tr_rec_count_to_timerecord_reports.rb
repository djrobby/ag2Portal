class AddTrRecCountToTimerecordReports < ActiveRecord::Migration
  def change
    add_column :timerecord_reports, :tr_rec_count, :integer
  end
end
