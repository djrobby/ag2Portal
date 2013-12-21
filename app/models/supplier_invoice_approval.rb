class SupplierInvoiceApproval < ActiveRecord::Base
  belongs_to :supplier_invoice
  belongs_to :approver, :class_name => 'User'
  attr_accessible :approval_date, :approved_amount, :remarks,
                  :supplier_invoice_id, :approver_id

  has_paper_trail

  validates :supplier_invoice,  :presence => true
  validates :approver,          :presence => true
  validates :approval_date,     :presence => true
end
