# encoding: utf-8

class PreReading < ActiveRecord::Base
  include ModelsModule

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
                  :meter_id, :subscriber_id, :reading_route_id, :reading_1_id, :reading_2_id,
                  :created_by, :updated_by, :lat, :lng

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
  validates :reading_date,                  :presence => true, :if => "!reading_index.blank?"
  validates_numericality_of :reading_index, :only_integer => true,
                                            :greater_than_or_equal_to => 0,
                                            :message => :reading_invalid,
                                            :if => "!reading_date.blank?"
  validate :check_date

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    attributes = [I18n.t('activerecord.attributes.reading.reading_route_id'),
                  I18n.t('activerecord.attributes.reading.sequence'),
                  I18n.t('activerecord.attributes.reading.subscriber'),
                  I18n.t('activerecord.attributes.reading.address'),
                  I18n.t('activerecord.attributes.reading.meter'),
                  I18n.t('activerecord.attributes.reading.billing_period_2'),
                  I18n.t('activerecord.attributes.reading.reading_2_date'),
                  I18n.t('activerecord.attributes.reading.reading_2_index'),
                  I18n.t('activerecord.attributes.reading.reading_days'),
                  I18n.t('activerecord.attributes.reading.consumption_2'),
                  I18n.t('activerecord.attributes.reading.billing_period_1'),
                  I18n.t('activerecord.attributes.reading.reading_1_date'),
                  I18n.t('activerecord.attributes.reading.reading_1_index'),
                  I18n.t('activerecord.attributes.reading.billing_period_id'),
                  I18n.t('activerecord.attributes.reading.reading_date'),
                  I18n.t('activerecord.attributes.reading.reading'),
                  I18n.t('activerecord.attributes.reading.reading_days'),
                  I18n.t('activerecord.attributes.reading.consumption'),
                  I18n.t('activerecord.report.reading.incidences') ]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |pre_reading|
        csv << [  pre_reading.try(:reading_route).try(:to_label),
                  pre_reading.reading_sequence,
                  pre_reading.try(:subscriber).try(:to_label),
                  pre_reading.try(:subscriber).try(:address_1),
                  pre_reading.try(:meter).try(:to_label),
                  pre_reading.reading_2.try(:billing_period).try(:period),
                  pre_reading.reading_2.try(:to_reading_date),
                  pre_reading.reading_2.try(:reading_index),
                  pre_reading.reading_2.try(:reading_days),
                  pre_reading.reading_2.try(:consumption_total_period),
                  pre_reading.reading_1.try(:billing_period).try(:period),
                  pre_reading.reading_1.try(:to_reading_date),
                  pre_reading.reading_1.try(:reading_index),
                  pre_reading.try(:billing_period).try(:period),
                  pre_reading.to_reading_date,
                  pre_reading.reading_index,
                  pre_reading.try(:reading_days),
                  pre_reading.try(:consumption_total_period),
                  pre_reading.reading_incidence_types.pluck(:name).join(", ")]
      end
    end
  end

  def to_reading_date
    formatted_timestamp(reading_date) if reading_date
  end

  def reading_days
    _d = 0
    if !reading_1.nil?
      if reading_date && reading_1.reading_date
        _d = ((reading_date.to_time - reading_1.reading_date.to_time)/86400).to_i
      end
    end
    _d
  end

  def consumption_total_period
    # @readings = Reading.where(billing_period_id: billing_period_id, subscriber_id: subscriber_ids).where('reading_type_id NOT IN (?)',[1,2,5,6]).group_by(&:reading_1_id)
    readings = subscriber.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    total = 0
    readings.each do |reading|
      total += reading[1].last.consumption
    end
    return total
  end

  def incomplete?
    reading_date.blank? || reading_index.blank?
  end

  def consumption
    unless reading_index_1.nil? or reading_index.nil?
      if reading_index_1 <= reading_index
        reading_index - reading_index_1
      else
        # vuelta de contador
        (((10 ** meter.meter_model.digits)-1) - reading_index_1) + reading_index
      end
    else
      nil
    end
  end

  private

  def check_date
    if !reading_date.blank?
      if reading_1 and reading_1.reading_date and reading_1.reading_date > reading_date
        errors[:reading_date] << " no puede ser inferior que la del periodo anterior"
      end
    end
  end
end
