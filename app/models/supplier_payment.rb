class SupplierPayment < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :supplier_invoice
  belongs_to :payment_method
  belongs_to :approver, :class_name => 'User'
  belongs_to :supplier_invoice_approval
  attr_accessible :amount, :payment_date, :remarks,
                  :supplier_id, :supplier_invoice_id,
                  :approver_id, :payment_method_id,
                  :supplier_invoice_approval_id

  has_paper_trail

  validates :supplier,          :presence => true
  validates :supplier_invoice,  :presence => true
  validates :payment_method,    :presence => true
  validates :approver,          :presence => true
  validates :payment_date,      :presence => true
  validates :amount,            :presence => true,
                                :numericality => { :greater_than => 0, :less_than_or_equal_to => :invoice_debt }

  #
  # Calculated fields
  #
  def invoice_debt
    supplier_invoice.debt
  end
end
