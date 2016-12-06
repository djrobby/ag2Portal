class TariffSchemeItem < ActiveRecord::Base
  belongs_to :tariff_scheme
  belongs_to :tariff
  attr_accessible :tariff_scheme_id, :tariff_id

  has_paper_trail

  validates :tariff_scheme, :presence => true
  validates :tariff,        :presence => true
end
