class MeterModel < ActiveRecord::Base
  belongs_to :meter_type
  belongs_to :meter_brand
  attr_accessible :model, :meter_type_id, :meter_brand_id, :digits, :dials, :letter_id

  has_many :meters

  has_paper_trail

  validates :meter_type,    :presence => true
  validates :meter_brand,   :presence => true
  validates :model,         :presence => true
  validates :digits,        :presence => true
  validates :letter_id,     :length => { :is => 1 }, allow_blank: true,
                            :uniqueness => { :scope => :meter_brand_id }

  # Scopes
  scope :by_brand_model, -> { order(:meter_brand_id, :model) }

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records


  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.model.blank?
      full_name += self.model
    end
    if !self.meter_brand.blank?
      full_name += " (" + self.meter_brand.brand + ")"
    end
    full_name
  end

  private

  def fields_to_uppercase
    if !self.model.blank?
      self[:model].upcase!
    end
    if !self.letter_id.blank?
      self[:letter_id].upcase!
    end
  end

  # Before destroy
  def check_for_dependent_records
    # Check for meters
    if meters.count > 0
      errors.add(:base, I18n.t('activerecord.models.meter_model.check_for_meters'))
      return false
    end
  end
end
