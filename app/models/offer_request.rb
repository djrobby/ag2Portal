# encoding: utf-8

class OfferRequest < ActiveRecord::Base
  include ModelsModule

  belongs_to :payment_method
  belongs_to :project
  belongs_to :approved_offer, class_name: 'Offer'
  belongs_to :approver, class_name: 'User'
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  belongs_to :organization
  attr_accessible :approval_date, :deadline_date, :request_date, :request_no, :remarks,
                  :discount_pct, :discount, :payment_method_id, :project_id, :approved_offer_id,
                  :approver_id, :store_id, :work_order_id, :charge_account_id, :organization_id, :totals
  attr_accessible :offer_request_items_attributes, :offer_request_suppliers_attributes

  has_many :offer_request_items, dependent: :destroy
  has_many :offer_request_suppliers, dependent: :destroy
  has_many :products, through: :offer_request_items
  has_many :offers

  # Nested attributes
  accepts_nested_attributes_for :offer_request_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  accepts_nested_attributes_for :offer_request_suppliers,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :offer_request_items, :offer_request_suppliers

  validates :request_date,    :presence => true
  validates :request_no,      :presence => true,
                              :length => { :is => 22 },
                              :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :payment_method,  :presence => true
  validates :project,         :presence => true
  validates :organization,    :presence => true

  # Callbacks
  before_destroy :check_for_dependent_records
  before_save :calculate_and_store_totals

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
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.request_no")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.request_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.deadline_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.project")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.work_order")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.charge_account")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.store")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.payment_method")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.approved_offer")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.approval_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.offer_request.approver"))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.formatted_date(i.request_date) unless i.request_date.blank?
        i002 = i.formatted_date(i.deadline_date) unless i.deadline_date.blank?
        i003 = i.formatted_timestamp(i.approval_date.utc.getlocal) unless i.approval_date.blank?

        csv << [  i.try(:project).try(:company).try(:id),
                  i.try(:project).try(:company).try(:name),
                  i.full_no,
                  i001,
                  i002,
                  i.try(:project).try(:full_name),
                  i.try(:work_order).try(:full_name),
                  i.try(:charge_account).try(:full_name),
                  i.try(:store).name,
                  i.try(:payment_method).try(:description),
                  i.try(:approved_offer).try(:full_name),
                  i003,
                  i.try(:approver).try(:email)]
      end
    end
  end
  
  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.request_date.blank?
      full_name += " " + formatted_date(self.request_date)
    end
    full_name
  end

  def full_no
    # Request no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    request_no.blank? ? "" : request_no[0..11] + '-' + request_no[12..15] + '-' + request_no[16..21]
  end

  #
  # Calculated fields
  #
  def subtotal
    offer_request_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def bonus
    (discount_pct / 100) * subtotal if !discount_pct.blank?
  end

  def taxable
    subtotal - bonus - discount
  end

  def taxes
    offer_request_items.reject(&:marked_for_destruction?).sum(&:net_tax)
  end

  def total
    taxable + taxes
  end

  def quantity
    offer_request_items.sum(:quantity)
  end

  # Returns multidimensional array containing different tax type in each line
  # Each line contains 5 elements: Id, Description, Tax %, Net amount & Net tax
  def tax_breakdown
    global_tax_breakdown(offer_request_items, true)
  end

  #
  # Class (self) user defined methods
  #
  def self.approved(organization)
    if !organization.blank?
      where('NOT approved_offer_id IS NULL AND organization_id = ?', organization).order(:request_no)
    else
      where('NOT approved_offer_id IS NULL').order(:request_no)
    end
  end

  def self.approved_and_this(organization, request_id)
    if !organization.blank?
      where('(NOT approved_offer_id IS NULL OR id = ?) AND organization_id = ?', request_id, organization).order(:request_no)
    else
      where('NOT approved_offer_id IS NULL OR id = ?', request_id).order(:request_no)
    end
  end

  def self.not_approved(organization)
    if !organization.blank?
      where('approved_offer_id IS NULL AND organization_id = ?', organization).order(:request_no)
    else
      where('approved_offer_id IS NULL').order(:request_no)
    end
  end

  #
  # Records navigator
  #
  def to_first
    OfferRequest.order("request_no desc").first
  end

  def to_prev
    OfferRequest.where("request_no > ?", request_no).order("request_no desc").last
  end

  def to_next
    OfferRequest.where("request_no < ?", request_no).order("request_no desc").first
  end

  def to_last
    OfferRequest.order("request_no desc").last
  end

  searchable do
    text :request_no
    string :request_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :payment_method_id
    integer :id, :multiple => true          # Multiple search values accepted in one search (current_suppliers)
    integer :project_id, :multiple => true  # Multiple search values accepted in one search (current_projects)
    integer :store_id
    integer :work_order_id
    integer :charge_account_id
    integer :approved_offer_id
    integer :approver_id
    date :request_date
    date :deadline_date
    date :approval_date
    integer :organization_id
    string :sort_no do
      request_no
    end
  end

  private

  def calculate_and_store_totals
    self.totals = total
  end

  def check_for_dependent_records
    # Check for offers
    if offers.count > 0
      errors.add(:base, I18n.t('activerecord.models.offer_request.check_for_offers'))
      return false
    end
  end
end
