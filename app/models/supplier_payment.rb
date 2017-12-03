class SupplierPayment < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :supplier_invoice
  belongs_to :payment_method
  belongs_to :approver, :class_name => 'User'
  belongs_to :supplier_invoice_approval
  belongs_to :organization
  attr_accessible :amount, :payment_date, :payment_no, :remarks,
                  :supplier_id, :supplier_invoice_id,
                  :approver_id, :payment_method_id,
                  :supplier_invoice_approval_id, :organization_id

  has_many :cash_desk_closing_items

  has_paper_trail

  validates :supplier,          :presence => true
  validates :supplier_invoice,  :presence => true
  validates :payment_method,    :presence => true
  validates :approver,          :presence => true
  validates :payment_no,        :presence => true,
                                :length => { :is => 14 },
                                :format => { with: /\A\d+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :organization_id }
  validates :payment_date,      :presence => true
  validates :amount,            :presence => true,
                                :numericality => { :greater_than => 0, :less_than_or_equal_to => :invoice_debt }
  validates :organization,      :presence => true

  def full_no
    # Payment no (Organization id & year & sequential number) => OOOO-YYYY-NNNNNN
    payment_no.blank? ? "" : payment_no[0..3] + '-' + payment_no[4..7] + '-' + payment_no[8..13]
  end

  #
  # Calculated fields
  #
  def invoice_debt
    supplier_invoice.nil? ? 0 : supplier_invoice.debt
  end

  #
  # Records navigator
  #
  def to_first
    SupplierPayment.order("id desc").first
  end

  def to_prev
    SupplierPayment.where("id > ?", id).order("id desc").last
  end

  def to_next
    SupplierPayment.where("id < ?", id).order("id desc").first
  end

  def to_last
    SupplierPayment.order("id desc").last
  end

  searchable do
    text :payment_no
    string :payment_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :id
    integer :payment_method_id
    integer :supplier_id
    integer :supplier_invoice_id
    integer :approver_id
    integer :supplier_invoice_approval_id
    date :payment_date
    integer :organization_id
    string :sort_no do
      payment_no
    end
  end
end
