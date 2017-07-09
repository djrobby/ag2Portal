class SepaSchemeType < ActiveRecord::Base
  attr_accessible :name

  has_paper_trail

  validates :name,  :presence => true

  # Scopes
  scope :by_id, -> { order(:id) }
  scope :by_name, -> { order(:name) }
end
