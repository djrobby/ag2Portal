class Center < ActiveRecord::Base
  belongs_to :town
  attr_accessible :active, :name, :town_id, :code
  delegate :name, :to => :town, :allow_nil => true, :prefix => true

  has_many :subscribers
  has_many :service_points

  has_paper_trail

  validates :town,        :presence => true
  validates :name,        :presence => true
  validates :code,        :presence => true,
                          :length => { :is => 3 },
                          :uniqueness => { :scope => :town_id },
                          :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid }

  # Scopes
  scope :by_town, -> { order('centers.town_id, centers.name') }
  #
  scope :for_dropdown_by_town, -> town {
    joins(:town)
    .select("centers.id, CONCAT(centers.code, ' (', towns.name, ')') to_label_")
    .where(town_id: town)
    .by_town
  }
  scope :for_dropdown, -> {
    joins(:town)
    .select("centers.id, CONCAT(centers.code, ' (', towns.name, ')') to_label_")
    .by_town
  }

  # Callbacks
  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def to_label
    "#{code} (#{town.name})"
  end

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  #
  # Class (self) user defined methods
  #
  def self.dropdown(town=nil)
    if town.present?
      self.for_dropdown_by_town(town)
    else
      self.for_dropdown
    end
  end

  private

  # Before destroy
  def check_for_dependent_records
    # Check for subscribers
    if subscribers.count > 0
      errors.add(:base, I18n.t('activerecord.models.center.check_for_subscribers'))
      return false
    end
  end
end
