class Caliber < ActiveRecord::Base
  attr_accessible :caliber

  has_paper_trail

  validates :caliber, :presence => true

  has_many :meters
end
