class PreReading < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :reading_route
  belongs_to :reading_1, class_name: "Reading"
  belongs_to :reading_2, class_name: "Reading"
  attr_accessible :reading_1, :reading_2, :reading_date, :reading_index, :reading_index_1, :reading_index_2,
                  :reading_sequence, :reading_variant,
                  :project_id, :billing_period_id, :billing_frequency_id, :reading_type_id,
                  :meter_id, :subscriber_id, :reading_route_id, :reading_1_id, :reading_2_id

  has_many :pre_reading_incidences
  has_and_belongs_to_many :reading_incidence_types, join_table: "pre_reading_incidences"

  has_paper_trail

  validates :project,                       :presence => true
  validates :billing_period,                :presence => true
  validates :billing_frequency,             :presence => true
  validates :reading_type,                  :presence => true
  validates :meter,                         :presence => true
  validates :subscriber,                    :presence => true
  validates :reading_route,                 :presence => true
  validates :reading_date,                  :presence => true
  validates_numericality_of :reading_index, :only_integer => true,
                                            :greater_than_or_equal_to => 0,
                                            :message => :reading_invalid
  validate :check_date

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }

  def incomplete?
    reading_date.blank?
  end

  def consumption
    unless reading_index_1.nil? or reading_index.nil?
      if reading_index_1 <= reading_index
        reading_index - reading_index_1
      else
        # vuelta de contador
        ((10 ** meter.meter_model.digits) - reading_index_1) + reading_index
      end
    else
      nil
    end
  end

  private

  def check_date
    if reading_1 and reading_1.reading_date and reading_1.reading_date > reading_date
      errors[:reading_date] << " no puede ser inferior que la del periodo anterior"
    end
  end
end
