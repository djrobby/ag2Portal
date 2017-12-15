class ChangeShoudEstimateInReadingIncidenceTypes < ActiveRecord::Migration
  def change
    change_column :reading_incidence_types, :should_estimate, :boolean, null: false, default: false
  end
end
