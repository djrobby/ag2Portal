class AddNonBillableToSubscribers < ActiveRecord::Migration
  def self.up
    add_column :subscribers, :non_billable, :boolean, null: false, default: false

    Subscriber.find_each do |p|
      p.update_column(:non_billable, false)
    end
  end

  def self.down
    remove_column :subscribers, :non_billable
  end
end
