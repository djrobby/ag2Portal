class Regulation < ActiveRecord::Base
  belongs_to :project
  belongs_to :regulation_type

  attr_accessible :description, :ending_at, :starting_at, :project_id, :regulation_type_id

  has_many :billable_items

  has_paper_trail

  validates :project,         :presence => true
  validates :regulation_type, :presence => true
  validates :description,     :presence => true
  validates :starting_at,     :presence => true

  validate :ending_at_cannot_be_less_than_started_at

  def to_label
    if ending_at.blank?
      "#{type_description} #{regulation_description} #{regulation_starting_at}"
    else
      "#{type_description} #{regulation_description} #{regulation_starting_at}-#{regulation_ending_at}"
    end
  end

  def type_description
    regulation_type.description.strip rescue ''
  end

  def regulation_description
    description.strip rescue ''
  end

  def regulation_starting_at
    I18n.l(starting_at) rescue ''
  end

  def regulation_ending_at
    I18n.l(ending_at) rescue ''
  end

  private

  def ending_at_cannot_be_less_than_started_at
    if (!ending_at.blank? and !starting_at.blank?) and ending_at < starting_at
      errors.add(:ending_at, :date_invalid)
    end
  end
end
