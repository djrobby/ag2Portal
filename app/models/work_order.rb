class WorkOrder < ActiveRecord::Base
  belongs_to :work_order_type
  belongs_to :work_order_status
  belongs_to :work_order_labor
  belongs_to :charge_account
  belongs_to :project
  belongs_to :area
  belongs_to :store
  attr_accessible :closed_at, :completed_at, :order_no, :started_at,
                  :work_order_labor_id, :work_order_status_id, :work_order_type_id,
                  :charge_account_id, :project_id, :area_id, :store_id

  has_many :work_order_items, dependent: :destroy
  has_many :purchase_orders

  has_paper_trail

  validates :order_no,              :presence => true,
                                    :length => { :in => 7..17 },
                                    :uniqueness => true
  validates :charge_account_id,     :presence => true
  validates :project_id,            :presence => true
  validates :work_order_labor_id,   :presence => true
  validates :work_order_status_id,  :presence => true
  validates :work_order_type_id,    :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for purchase_orders
    if purchase_orders.count > 0
      errors.add(:base, I18n.t('activerecord.models.charge_account.check_for_purchase_orders'))
      return false
    end
  end
end
