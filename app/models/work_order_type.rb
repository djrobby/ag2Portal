class WorkOrderType < ActiveRecord::Base
  belongs_to :organization
  belongs_to :charge_account
  belongs_to :work_order_area
  attr_accessible :name, :organization_id, :charge_account_id, :work_order_area_id, :subscriber_meter,
                  :work_order_type_accounts_attributes

  has_many :work_orders
  has_many :work_order_type_accounts, dependent: :destroy
  has_many :work_order_labors

  # Nested attributes
  accepts_nested_attributes_for :work_order_type_accounts,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :work_order_type_accounts

  validates :name,            :presence => true
  validates :work_order_area, :presence => true
  validates :organization,    :presence => true

  # Scopes
  scope :by_name, -> { order(:name) }
  #
  scope :belongs_to_organization, -> organization { where("organization_id = ?", organization).by_name }
  scope :belongs_to_account, -> account { where("charge_account_id = ?", account).by_name }
  scope :belongs_to_area, -> area { where("work_order_area_id = ?", area).by_name }

  before_destroy :check_for_dependent_records

  def short_name
    name[0,20]
  end

  private

  def check_for_dependent_records
    # Check for work orders
    if work_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.work_order_type.check_for_work_orders'))
      return false
    end
  end
end
