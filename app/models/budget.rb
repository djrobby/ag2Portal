# encoding: utf-8

class Budget < ActiveRecord::Base
  include ModelsModule

  belongs_to :project
  belongs_to :organization
  belongs_to :budget_period
  belongs_to :approver, class_name: 'User'
  attr_accessible :budget_no, :description, :project_id, :organization_id,
                  :budget_period_id, :approver_id, :approval_date
  attr_accessible :budget_items_attributes

  has_many :budget_items, dependent: :destroy
  has_many :budget_ratios, dependent: :destroy
  has_many :charge_accounts, through: :budget_items
  has_many :charge_groups, through: :charge_accounts
  has_many :budget_headings, through: :charge_groups

  # Nested attributes
  accepts_nested_attributes_for :budget_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :budget_items

  validates :description,   :presence => true
  validates :budget_no,     :presence => true,
                            :length => { :is => 20 },
                            :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => :organization_id }
  validates :project,       :presence => true
  validates :budget_period, :presence => true
  validates :organization,  :presence => true

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.description.blank?
      full_name += " " + self.description[0,40]
    end
    full_name
  end

  def full_no
    # Budget no. (Project code & budget period code) => PPPPPPPPPPPP-BBBBBBBB
    budget_no.blank? ? "" : budget_no[0..11] + '-' + budget_no[12..19]
  end

  def summary
    description.blank? ? "" : description[0,40]
  end

  #
  # Calculated fields
  #
  # By Items
  def total_income
    _result = 0
    budget_items.each do |i|
      _flow = i.charge_account.charge_group.flow rescue 0
      if (_flow == 1 || _flow == 3) && !i.annual.blank?
        _result += i.annual
      end
    end
    _result
  end

  def total_expenditure
    _result = 0
    budget_items.each do |i|
      _flow = i.charge_account.charge_group.flow rescue 0
      if (_flow == 2 || _flow == 3) && !i.annual.blank?
        _result += i.annual
      end
    end
    _result
  end

  def total
    total_income - total_expenditure
  end

  def total_01
    budget_items.sum("month_01")
  end

  def total_02
    budget_items.sum("month_02")
  end

  def total_03
    budget_items.sum("month_03")
  end

  def total_04
    budget_items.sum("month_04")
  end

  def total_05
    budget_items.sum("month_05")
  end

  def total_06
    budget_items.sum("month_06")
  end

  def total_07
    budget_items.sum("month_07")
  end

  def total_08
    budget_items.sum("month_08")
  end

  def total_09
    budget_items.sum("month_09")
  end

  def total_10
    budget_items.sum("month_11")
  end

  def total_11
    budget_items.sum("month_11")
  end

  def total_12
    budget_items.sum("month_12")
  end

  def total_annual
    _result = 0
    budget_items.each do |i|
      if i.amount != 0
        _result += i.amount
      else
        _result += (i.month_01 + i.month_02 + i.month_03 + i.month_04 + i.month_04 + i.month_06 +
                    i.month_07 + i.month_08 + i.month_09 + i.month_10 + i.month_11 + i.month_12)
      end
    end
    _result
  end

  def total_corrected
    budget_items.sum("corrected_amount")
  end

  def total_00
    _result = 0
    budget_items.each do |i|
      if !i.month_03.blank?
        _flow = i.charge_account.charge_group.flow rescue 0
        case _flow
        when 1
          _result += i.month_03
        when 2
          _result -= i.month_03
        end
      end
    end
    _result
  end

  # By Groups

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
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.project")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.budget_no")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.description")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.budget_period")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.total_income")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.total_expenditure")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.approval_date")),
                    array[0].sanitize(I18n.t("activerecord.attributes.budget.approver"))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        i001 = i.raw_number(i.total_income, 2) unless i.total_income.blank?
        i002 = i.raw_number(i.total_expenditure, 2) unless i.total_expenditure.blank?
        i003 = i.formatted_timestamp(i.approval_date.utc.getlocal) unless i.approval_date.blank?
        csv << [  i.try(:project).try(:company).try(:id),
                  i.try(:project).try(:company).try(:name),
                  i.try(:project).try(:full_name),
                  i.try(:full_no),
                  i.description,
                  i.try(:budget_period).try(:full_name),
                  i001,
                  i002,
                  i003,
                  i.approver.email]
      end
    end
  end

  #
  # Records navigator
  #
  def to_first
    Budget.order("budget_no").first
  end

  def to_prev
    Budget.where("budget_no < ?", id).order("budget_no").last
  end

  def to_next
    Budget.where("budget_no > ?", id).order("budget_no").first
  end

  def to_last
    Budget.order("budget_no").last
  end

  searchable do
    text :budget_no, :description
    string :budget_no, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :project_id
    integer :budget_period_id
    integer :organization_id
    string :sort_no do
      budget_no
    end
  end
end
