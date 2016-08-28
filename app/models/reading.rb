class Reading < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :reading_route
  attr_accessible :reading_date, :reading_index, :reading_sequence, :reading_variant,
                  :project_id, :billing_period_id, :billing_frequency_id, :reading_type_id,
                  :meter_id, :subscriber_id, :reading_route_id

  has_many :reading_incidences
  has_and_belongs_to_many :reading_incidence_types, join_table: "reading_incidences"

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

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }

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
end
