class Api::V1::WorkOrdersSerializer < ::Api::V1::BaseSerializer
  attributes :id, :closed_at, :started_at, :completed_at, :master_order_id,
                  :order_no, :description, :text

  has_many :suborders, class_name: 'WorkOrder', foreign_key: 'master_order_id'

  def text
    full_name = full_no
    full_name += " " + summary
    full_name
  end

  def summary
    description.blank? ? "N/A" : description[0,40]
  end

  def full_no
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN M
    order_no.blank? ? "" : order_no[0..11] + '-' + order_no[12..15] + '-' + order_no[16..21] + complete_full_no_if_suborders
  end

  def have_suborders?
    suborders.count > 0 ? true : false
  end

  def complete_full_no_if_suborders
    have_suborders? ? I18n.t('activerecord.attributes.work_order.master_c') : ""
  end
end
