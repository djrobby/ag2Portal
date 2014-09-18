class Budget < ActiveRecord::Base
  belongs_to :project
  belongs_to :organization
  belongs_to :budget_period
  belongs_to :approver, class_name: 'User'
  attr_accessible :budget_no, :description, :project_id, :organization_id,
                  :budget_period_id, :approver_id, :approval_date
  
  has_many :budget_items, dependent: :destroy

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
    # Budget no. (Project code & budget period code & sequential number) => PPPPPPPPPPPP-BBBBBBBB
    budget_no.blank? ? "" : budget_no[0..11] + '-' + budget_no[12..19]
  end

  def summary
    description.blank? ? "" : description[0,40]     
  end

  #
  # Calculated fields
  #
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
    _result = 0
    budget_items.each do |i|
      if !i.month_01.blank?
        _flow = i.charge_account.charge_group.flow rescue 0
        case _flow
        when 1
          _result += i.month_01        
        when 2
          _result -= i.month_01        
        end
      end
    end
    _result
  end

  def total_02
    _result = 0
    budget_items.each do |i|
      if !i.month_02.blank?
        _flow = i.charge_account.charge_group.flow rescue 0
        case _flow
        when 1
          _result += i.month_02        
        when 2
          _result -= i.month_02        
        end
      end
    end
    _result
  end

  def total_03
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

  #
  # Records navigator
  #
  def to_first
    Budget.order("buget_no").first
  end

  def to_prev
    Budget.where("buget_no < ?", id).order("buget_no").last
  end

  def to_next
    Budget.where("buget_no > ?", id).order("buget_no").first
  end

  def to_last
    Budget.order("buget_no").last
  end

  searchable do
    text :budget_no, :description
    string :budget_no
    integer :project_id
    integer :budget_period_id
    integer :organization_id
  end
end
