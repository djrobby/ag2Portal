# encoding: utf-8

class SupplierPayment < ActiveRecord::Base
  include ModelsModule

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

  # Scopes
  scope :by_no, -> { order(:payment_no) }
  # Pending of Cash desk closing
  scope :no_cash_desk_closing_yet, -> w {
    joins(supplier_invoice: :project)
    .joins(:payment_method)
    .joins('LEFT JOIN cash_desk_closing_items ON supplier_payments.id=cash_desk_closing_items.supplier_payment_id')
    .where(w)
    .where('cash_desk_closing_items.supplier_payment_id IS NULL')
    .by_no
  }

  # Methods
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

  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    attributes = [  array[0].sanitize("Id" + " " + I18n.t("activerecord.models.company.one")),
                    array[0].sanitize(I18n.t("activerecord.models.company.one")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.payment_no")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.payment_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.supplier_invoice")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.supplier")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.payment_method")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.approver")),
                    array[0].sanitize(I18n.t("activerecord.attributes.supplier_payment.amount")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer.charge_account")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer.store")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer.approval_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer.approver")) ]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.raw_number(i.amount, 2) unless i.amount.blank?
        csv << [  i.try(:supplier_invoice).try(:project).try(:company).try(:id),
                  i.try(:supplier_invoice).try(:project).try(:company).try(:name),
                  i.full_no,
                  i.payment_date,
                  i.try(:supplier_invoice).try(:invoice_no) ,
                  i.try(:supplier).try(:full_name),
                  i.try(:payment_method).try(:description),
                  i.try(:approver).try(:email),
                  i001]
      end
    end
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
