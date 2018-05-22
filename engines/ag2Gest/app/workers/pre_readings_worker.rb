class PreReadingsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def expiration
    @expiration ||= 60*60*24*30 # 30 days
  end

  def perform(pre_readings_ids, user_id)
    bgw = BackgroundWork.find_by_work_no(self.jid)
    pre_readings = PreReading.where(id: pre_readings_ids)
    @readings = []
    pre_readings.each do |pre_reading|
      begin
        reading = to_reading(pre_reading, user_id)
        if reading.blank?
          bgw.update_attributes(failure: bgw.failure + "#{pre_reading.id}, ")
        else
          @readings << reading
        end
      rescue
        bgw = BackgroundWork.find_by_work_no(self.jid)
        bgw.update_attributes(failure: bgw.failure + "#{pre_reading.id}, ")
        next
      end
    end
    bgw = BackgroundWork.find_by_work_no(self.jid)
    bgw.update_attributes(total: @readings.count)
  end

  # Add new
  def to_reading(pre_reading, user_id)
    reading = nil
    if !pre_reading.reading_incidence_types.empty? || !pre_reading.reading_index.nil?
      if pre_reading.subscriber_id.nil?
        if pre_reading.meter.is_shared?
          pre_reading.meter.subscribers.actives.each do |s|
            reading = Reading.where(project_id: pre_reading.project_id, billing_period_id: pre_reading.billing_period_id, meter_id: pre_reading.meter_id, subscriber_id: s.id, reading_date: pre_reading.reading_date, reading_type_id: pre_reading.reading_type_id)
            if reading.blank?
              reading = new_reading(pre_reading, s.service_point_id, s.id, user_id)
              if reading.save
                new_reading_new_incidences(pre_reading)
              end
            else
              reading_exists_new_incidences(pre_reading, reading)
            end
          end
          pre_reading.destroy
          r = true
        else
          reading = Reading.where(project_id: pre_reading.project_id, billing_period_id: pre_reading.billing_period_id, meter_id: pre_reading.meter_id, subscriber_id: nil, reading_date: pre_reading.reading_date, reading_type_id: pre_reading.reading_type_id)
          if reading.blank?
            reading = new_reading(pre_reading, pre_reading.meter.service_points.first.id, nil, user_id)
            if reading.save
              new_reading_new_incidences(pre_reading)
              pre_reading.destroy
              r = true
            end
          else
            reading_exists_new_incidences(pre_reading, reading)
            pre_reading.destroy
            r = true
          end
        end
      else
        reading = Reading.where(project_id: pre_reading.project_id, billing_period_id: pre_reading.billing_period_id, meter_id: pre_reading.meter_id, subscriber_id: pre_reading.subscriber_id, reading_date: pre_reading.reading_date, reading_type_id: pre_reading.reading_type_id)
        if reading.blank?
          reading = new_reading(pre_reading, Subscriber.find(pre_reading.subscriber_id).service_point_id, pre_reading.subscriber_id, user_id)
          if reading.save
            new_reading_new_incidences(pre_reading)
            pre_reading.destroy
            r = true
          end
        else
          reading_exists_new_incidences(pre_reading, reading)
          pre_reading.destroy
        end
      end
    end
    return reading
  end

  # Return new Reading
  def new_reading(pre_reading, service_point_id, subscriber_id, user_id)
    return Reading.new( project_id: pre_reading.project_id,
                        billing_period_id: pre_reading.billing_period_id,
                        billing_frequency_id: pre_reading.billing_frequency_id,
                        reading_type_id: !pre_reading.reading_index.blank? ? pre_reading.reading_type_id : ReadingType::AUTO,
                        meter_id: pre_reading.meter_id,
                        service_point_id: service_point_id,
                        subscriber_id: subscriber_id,
                        coefficient: pre_reading.meter.shared_coefficient,
                        reading_route_id: pre_reading.reading_route_id,
                        reading_sequence: pre_reading.reading_sequence,
                        reading_variant: pre_reading.reading_variant,
                        reading_date: pre_reading.reading_date ,
                        reading_index: !pre_reading.reading_index.blank? ? pre_reading.reading_index : pre_reading.reading_index_1,
                        reading_index_1: pre_reading.reading_index_1,
                        reading_index_2: pre_reading.reading_index_2,
                        reading_1: pre_reading.reading_1,
                        reading_2: pre_reading.reading_2,
                        created_by: user_id )
  end

  # Create new Reading Incidences
  def new_reading_new_incidences(pre_reading)
    pre_reading.reading_incidence_types.each do |i|
      ReadingIncidence.create(reading_id: pre_reading.id, reading_incidence_type_id: i.id, created_at: Time.now)
    end
  end

  # Create new Reading Incidences (reading already exists)
  def reading_exists_new_incidences(pre_reading, reading_exists)
    pre_reading.reading_incidence_types.each do |i|
      if !reading_exists.first.reading_incidences.map(&:reading_incidence_type_id).include? i.id
        ReadingIncidence.create(reading_id: reading_exists.first.id, reading_incidence_type_id: i.id, created_at: Time.now)
      end
    end
  end
end
