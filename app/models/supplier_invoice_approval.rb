class SupplierInvoiceApproval < ActiveRecord::Base
  include ModelsModule
  
  belongs_to :supplier_invoice
  belongs_to :approver, :class_name => 'User'
  attr_accessible :approval_date, :approved_amount, :remarks,
                  :supplier_invoice_id, :approver_id

  has_many :supplier_payments

  has_paper_trail

  #validates :supplier_invoice,  :presence => true
  validates :approver,          :presence => true
  validates :approval_date,     :presence => true
  validates :approved_amount,   :presence => true,
                                :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => :invoice_debt }

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.supplier_invoice.invoice_no.blank?
      full_name += self.supplier_invoice.invoice_no
    end
    if !self.approver.blank?
      full_name += " " + self.approver.email
    end
    if !self.approval_date.blank?
      full_name += " " + formatted_date(self.approval_date)
    end
    if !self.approved_amount.blank?
      full_name += " " + formatted_number(self.approved_amount, 4)
    end
    full_name
  end

  #
  # Calculated fields
  #
  def invoice_debt
    supplier_invoice.debt
  end
end
