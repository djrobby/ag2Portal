class InventoryCountType < ActiveRecord::Base
  attr_accessible :name

  has_many :inventory_counts

  validates :name,  :presence => true,
                    :length => { :in => 5..30 }

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for inventory counts
    if inventory_counts.count > 0
      errors.add(:base, I18n.t('activerecord.models.inventory_count_type.check_for_inventory_counts'))
      return false
    end
  end
end
