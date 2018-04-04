# encoding: utf-8

class PreReading < ActiveRecord::Base
  include ModelsModule

  belongs_to :project
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :service_point
  belongs_to :reading_route
  belongs_to :reading_1, class_name: "Reading"
  belongs_to :reading_2, class_name: "Reading"
  attr_accessible :reading_1, :reading_2, :reading_date, :reading_index, :reading_index_1, :reading_index_2,
                  :reading_sequence, :reading_variant,
                  :project_id, :billing_period_id, :billing_frequency_id, :reading_type_id,
                  :meter_id, :subscriber_id, :service_point_id,
                  :reading_route_id, :reading_1_id, :reading_2_id,
                  :created_by, :updated_by, :lat, :lng

  has_many :pre_reading_incidences
  has_and_belongs_to_many :reading_incidence_types, join_table: "pre_reading_incidences"

  has_paper_trail

  validates :project,                       :presence => true
  validates :billing_period,                :presence => true
  validates :billing_frequency,             :presence => true
  validates :reading_type,                  :presence => true
  validates :meter,                         :presence => true
  # validates :subscriber,                    :presence => true
  validates :reading_route,                 :presence => true
  validates :reading_date,                  :presence => true, :if => "!reading_index.blank?"
  validates_numericality_of :reading_index, :only_integer => true,
                                            :greater_than_or_equal_to => 0,
                                            :allow_nil => true,
                                            :message => :reading_invalid
  validate :check_date

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }

  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    attributes = [array[0].sanitize(I18n.t('activerecord.attributes.reading.meter_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.pre_reading.service_point_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.subscriber_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.subscriber_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.address')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.reading_route_id')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.sequence')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + " " + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + " " + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + " " + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + " " + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpaa') + " " + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + " " + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + " " + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + " " + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + " " + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.lpa') + " " + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.la') + " " + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.la') + " " + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.la') + " " + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.la') + " " + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.la') + " " + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + " " + I18n.t('activerecord.attributes.reading.period')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + " " + I18n.t('activerecord.attributes.reading.reading_date')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + " " + I18n.t('activerecord.attributes.reading.reading')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + " " + I18n.t('activerecord.attributes.reading.days')),
                  array[0].sanitize(I18n.t('activerecord.attributes.reading.l') + " " + I18n.t('activerecord.attributes.reading.consumption')),
                  array[0].sanitize(I18n.t('activerecord.report.reading.incidences')) ]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |pre_reading|
        csv << [  pre_reading.try(:meter).try(:meter_code),
                  pre_reading.try(:service_point).try(:full_code),
                  pre_reading.try(:subscriber).try(:full_code),
                  pre_reading.try(:subscriber).try(:full_name_full),
                  pre_reading.try(:subscriber).try(:address_1),
                  pre_reading.try(:reading_route).try(:route_code),
                  pre_reading.reading_sequence,
                  pre_reading.reading_2.try(:billing_period).try(:period),
                  pre_reading.reading_2.try(:to_reading_date),
                  pre_reading.reading_2.try(:reading_index),
                  pre_reading.reading_2.try(:reading_days),
                  pre_reading.reading_2.try(:consumption_total_period),
                  pre_reading.reading_1.try(:billing_period).try(:period),
                  pre_reading.reading_1.try(:to_reading_date),
                  pre_reading.reading_1.try(:reading_index),
                  pre_reading.reading_1.try(:reading_days),
                  pre_reading.reading_1.try(:consumption_total_period),
                  pre_reading.pre_previous_reading.try(:billing_period).try(:period),
                  pre_reading.pre_previous_reading.try(:to_reading_date),
                  pre_reading.pre_previous_reading.try(:reading_index),
                  pre_reading.pre_previous_reading.try(:reading_days),
                  pre_reading.pre_previous_reading.try(:consumption_total_period),
                  pre_reading.try(:billing_period).try(:period),
                  pre_reading.to_reading_date,
                  pre_reading.reading_index,
                  pre_reading.try(:reading_days),
                  pre_reading.try(:pre_registered_consumption),
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
      else
        _d = nil
      end
    end
    _d
  end

  def consumption_total_period
    if !subscriber.blank?
      readings = subscriber.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    else
      readings = meter.readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    end
    total = 0
    readings.each do |reading|
      if readings[1].last.consumption.nil?
        total += readings[1].last.consumption
      else
        total = nil
      end
    end
    return total
  end

  def pre_consumption_total_period
    if !subscriber.blank?
      pre_readings = subscriber.pre_readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    else
      pre_readings = meter.pre_readings.where(billing_period_id: billing_period_id).where('reading_type_id IN (?)',[ReadingType::NORMAL,ReadingType::OCTAVILLA,ReadingType::RETIRADA,ReadingType::AUTO]).order(:reading_date).group_by(&:reading_1_id)
    end
    total = 0
    pre_readings.each do |pre_readings|
      if !pre_readings[1].last.consumption.nil?
        total += pre_readings[1].last.consumption
      else
        total = nil
      end
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

  #
  # Consumption bqsed on Previous chronological reading
  # (register consumption)
  #
  def pre_previous_readings(meter=self.meter_id, subscriber=self.subscriber_id, service_point=self.service_point_id)
    w = ''
    w = "readings.meter_id = #{meter}" if !meter.nil?
    if w == ''
      w = "readings.subscriber_id = #{subscriber}" if !subscriber.nil?
    else
      w += " AND readings.subscriber_id = #{subscriber}" if !subscriber.nil?
    end
    if w == ''
      w = "readings.service_point_id = #{service_point}" if !service_point.nil?
    else
      w += " AND readings.service_point_id = #{service_point}" if !service_point.nil?
    end
    Reading.where("readings.id<>? AND readings.reading_date<=?", self.id, self.reading_date.blank? ? Date.today : self.reading_date)
           .where(w).by_period_date
  end

  def pre_previous_reading(meter=self.meter_id, subscriber=self.subscriber_id, service_point=self.service_point_id)
    pr = nil
    pre_previous_readings = pre_previous_readings(meter, subscriber, service_point)
    if !pre_previous_readings.blank?
      # Are there readings with the same DATE and ID greater than the current one?
      pr_same_date = pre_previous_readings.where("readings.reading_date = ? AND readings.id > ?", self.reading_date.blank? ? Date.today : self.reading_date, self.id)
      if pr_same_date.blank?
        # First previous reading found
        pr = pre_previous_readings.first
      else
        # Discard the same date readings found, and use the first valid one
        pr = pre_previous_readings.where("readings.id NOT IN (?)", pr_same_date.pluck(:id)).first
      end
    end
    return pr
  end

  def pre_registered_consumption(meter=self.meter_id, subscriber=self.subscriber_id, service_point=self.service_point_id)
    pre_previous_reading = pre_previous_reading(meter, subscriber, service_point)
    if (reading_index.nil? || pre_previous_reading.nil?) || reading_type_id == ReadingType::INSTALACION
      0
    else
      (reading_index - pre_previous_reading.reading_index) rescue 0
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
