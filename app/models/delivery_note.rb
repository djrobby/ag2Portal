# encoding: utf-8

class DeliveryNote < ActiveRecord::Base
  include ModelsModule

  belongs_to :client
  belongs_to :payment_method
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :sale_offer
  belongs_to :organization
  attr_accessible :delivery_date, :delivery_no, :discount, :discount_pct, :remarks,
                  :client_id, :payment_method_id, :project_id, :store_id, :work_order_id,
                  :charge_account_id, :sale_offer_id, :organization_id,
                  :totals, :total_costs, :quantities
  attr_accessible :delivery_note_items_attributes

  has_many :delivery_note_items, dependent: :destroy
  has_many :products, through: :delivery_note_items
  #has_many :invoice_items

  # Nested attributes
  accepts_nested_attributes_for :delivery_note_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :delivery_note_items

  validates :delivery_date,   :presence => true
  validates :delivery_no,     :presence => true,
                              :length => { :is => 22 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :project,         :presence => true
  validates :organization,    :presence => true

  # Callbacks
  #before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.delivery_date.blank?
      full_name += " " + formatted_date(self.delivery_date)
    end
    if !self.work_order.blank?
      full_name += " " + self.work_order.full_name
    else
      if !self.client.blank?
        full_name += " " + self.client.full_name
      end
    end
    full_name
  end

  def partial_name
    partial_name = full_no
    if !self.delivery_date.blank?
      full_name += " " + formatted_date(self.delivery_date)
    end
    partial_name
  end

  def full_no
    # Delivery no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    delivery_no.blank? ? "" : delivery_no[0..11] + '-' + delivery_no[12..15] + '-' + delivery_no[16..21]
  end

  #
  # Calculated fields
  #
  def costs
    delivery_note_items.reject(&:marked_for_destruction?).sum(&:costs)
  end

  def subtotal
    delivery_note_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end

  def taxable
    subtotal - bonus - discount
  end

  def taxes
    delivery_note_items.reject(&:marked_for_destruction?).sum(&:net_tax)
  end

  def total
    taxable + taxes
  end

  def quantity
    delivery_note_items.sum("quantity")
  end

  # Returns multidimensional array containing different tax type in each line
  # Each line contains 5 elements: Id, Description, Tax %, Net amount & Net tax
  def tax_breakdown
    global_tax_breakdown(delivery_note_items, false)
  end

  #
  # Class (self) user defined methods
  #
  def self.find_by_product_and_company(_product, _company)
    joins(:project, :delivery_note_items).where('projects.company_id = ? AND delivery_note_items.product_id = ?', _company, _product)
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
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.delivery_no")),
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.delivery_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.project")),
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.project")),
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.store")),
                    array[0].sanitize(I18n.t("activerecord.attributes.purchase_order.charge_account_code")),
                    array[0].sanitize(I18n.t("activerecord.attributes.receipt_note.charge_account")),
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.quantity")),
                    array[0].sanitize(I18n.t("activerecord.attributes.delivery_note.costs"))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.formatted_date(i.delivery_date) unless i.delivery_date.blank?
        i002 = i.raw_number(i.quantity, 2) unless i.quantity.blank?
        i003 = i.raw_number(i.costs, 2) unless i.costs.blank?
        csv << [  i.try(:project).try(:company).try(:id),
                  i.try(:project).try(:company).try(:name),
                  i.full_no,
                  i001,
                  i.try(:project).try(:full_code),
                  i.try(:project).try(:name),
                  i.try(:store).try(:name),
                  i.try(:charge_account).try(:full_code),
                  i.try(:charge_account).try(:partial_name),
                  i002,
                  i003]
      end
    end
  end

  #
  # Records navigator
  #
  def to_first
    DeliveryNote.order("delivery_no desc").first
  end

  def to_prev
    DeliveryNote.where("delivery_no > ?", delivery_no).order("delivery_no desc").last
  end

  def to_next
    DeliveryNote.where("delivery_no < ?", delivery_no).order("delivery_no desc").first
  end

  def to_last
    DeliveryNote.order("delivery_no desc").last
  end

  searchable do
    text :delivery_no
    string :delivery_no, :multiple => true    # Multiple search values accepted in one search (inverse_no_search)
    integer :payment_method_id
    integer :project_id, :multiple => true
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :client_id
    date :delivery_date
    integer :organization_id
    string :sort_no do
      delivery_no
    end
  end

  private

  def calculate_and_store_totals
    self.totals = total
    self.total_costs = costs
    self.quantities = quantity
  end

  def check_for_dependent_records
    # Check for client invoice items
    if invoice_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.delivery_note.check_for_client_invoices'))
      return false
    end
  end
end
