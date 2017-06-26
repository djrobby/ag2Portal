class CashDeskClosing < ActiveRecord::Base
  belongs_to :organization
  belongs_to :company
  belongs_to :office
  belongs_to :project

  attr_accessible :closing_balance, :opening_balance, :last_closing_id,
                  :amount_collected, :invoices_collected, :amount_paid, :invoices_paid,
                  :organization_id, :company_id, :office_id, :project_id,
                  :created_by, :updated_by

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

  #
  # Class (self) user defined methods
  #
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

  def total_instruments
    cash_desk_closing_instruments.sum(:amount)
  end

  def total_items
    cash_desk_closing_items.sum(:amount)
  end

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
    integer :organization_id
    integer :project_id
    date :created_at
  end
end