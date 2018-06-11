class CashDeskClosing < ActiveRecord::Base
  include ModelsModule

  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :project

  attr_accessible :closing_balance, :opening_balance, :last_closing_id,
                  :amount_collected, :invoices_collected,
                  :amount_paid, :invoices_paid,
                  :amount_others, :quantity_others,
                  :organization_id, :company_id, :office_id, :project_id,
                  :created_by, :updated_by, :instruments_difference

  has_many :cash_desk_closing_items
  has_many :cash_desk_closing_instruments

  # Self join
  has_one :next_closing, class_name: 'CashDeskClosing', foreign_key: 'last_closing_id'
  belongs_to :last_closing, class_name: 'CashDeskClosing'

  # Scopes
  scope :by_date, -> { order(:created_at) }
  #
  scope :none, where("1 = 0")
  scope :by_user, -> u { where(created_by: u).by_date }
  scope :by_organization, -> x { where(organization_id: x).by_date }
  scope :by_company, -> x { where(company_id: x).by_date }
  scope :by_office, -> x { where(office_id: x).by_date }
  scope :by_project, -> x { where(project_id: x).by_date }
  scope :with_these_ids, -> ids {
    includes(:company, :project)
    .where(id: ids)
  }

  # Methods
  def difference_of_balance_due_to_rounding
    closing_balance - closing_balance.round(2)
  end

  def total_instruments
    cash_desk_closing_instruments.sum(:amount)
  end

  def total_items
    cash_desk_closing_items.sum(:amount)
  end

  def total_collections
    cash_desk_closing_items.where("client_payment_id IS NOT NULL").sum(:amount)
  end

  def total_payments
    cash_desk_closing_items.where("supplier_payment_id IS NOT NULL").sum(:amount)
  end

  def total_cash_movement
    cash_desk_closing_items.where("cash_movement_id IS NOT NULL").sum(:amount)
  end

  # For CSV
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
    attributes = [array[0].sanitize("Id"),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.company')),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.project')),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.opening_balance')),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.closing_balance')),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.invoices_collected_c')),

                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.amount_collected')),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.invoices_paid_c')),
                  array[0].sanitize(I18n.t('activerecord.attributes.cash_desk_closing.amount_paid')),
                  array[0].sanitize(I18n.t :created_at),
                  array[0].sanitize(I18n.t :created_by)]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      CashDeskClosing.uncached do
        array.find_each do |cdc|
          created_at = cdc == @time_record ? cdc.formatted_timestamp(cdc.created_at) : cdc.formatted_timestamp(cdc.created_at.utc.getlocal)
          created_by = User.find(cdc.created_by).email
          csv << [ cdc.id,
                   cdc.company.name,
                   cdc.project.to_label,
                   cdc.raw_number(cdc.opening_balance,4),
                   cdc.raw_number(cdc.closing_balance,4),
                   cdc.raw_number(cdc.invoices_collected,4),
                   cdc.raw_number(cdc.amount_collected,4),
                   cdc.raw_number(cdc.invoices_paid,4),
                   cdc.raw_number(cdc.amount_paid,4),
                   created_at,
                   created_by]
        end
      end
    end
  end

  def self.last_by_project(x)
    by_project(x).last
  end

  def self.last_by_office(x)
    by_office(x).last
  end

  def self.last_by_company(x)
    by_company(x).last
  end

  def self.last_by_organization(x)
    by_organization(x).last
  end

  def self.last_of_all
    by_date.last
  end

  #
  # Records navigator
  #
  def to_first
    CashDeskClosing.order("id").first
  end

  def to_prev
    CashDeskClosing.where("id < ?", id).order("id").last
  end

  def to_next
    CashDeskClosing.where("id > ?", id).order("id").first
  end

  def to_last
    CashDeskClosing.order("id").last
  end

  searchable do
    integer :id
    integer :office_id
    integer :company_id
    integer :organization_id
    integer :project_id
    date :created_at
    integer :created_by
  end
end
