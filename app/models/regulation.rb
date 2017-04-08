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
      "#{regulation_type.description} #{try(:description)} (#{I18n.l(starting_at)})"
    else
      "#{regulation_type.description} #{try(:description)} (#{I18n.l(starting_at)} - #{I18n.l(ending_at)})"
    end
  end

  private

  def ending_at_cannot_be_less_than_started_at
    if (!ending_at.blank? and !starting_at.blank?) and ending_at < starting_at
      errors.add(:ending_at, :date_invalid)
    end
  end
end
