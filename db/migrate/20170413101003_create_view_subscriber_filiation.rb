class CreateViewSubscriberFiliation < ActiveRecord::Migration
  def up
    execute "create view subscriber_filiations as
    SELECT s.id AS subscriber_id,
    CONCAT(LEFT(subscriber_code,4),'-',RIGHT(subscriber_code,7)) AS subscriber_code,
    IF(last_name IS NULL OR last_name='',company,CONCAT(last_name,', ',first_name)) AS name,
    CONCAT(
    IF(t.street_type_code IS NULL OR t.street_type_code='','',CONCAT(t.street_type_code,' ')),d.street_name,
    IF(s.street_number IS NULL OR s.street_number='','',CONCAT(' ',s.street_number)),
    IF(s.building IS NULL OR s.building='','',CONCAT(' ',s.building)),
    IF(s.floor IS NULL OR s.floor='','',CONCAT(' ',s.floor)),
    IF(s.floor_office IS NULL OR s.floor_office='','',CONCAT(' ',s.floor_office))
    ) AS supply_address,
    m.meter_code, s.use_id, s.reading_route_id, s.office_id, s.center_id, s.street_directory_id,
    CONCAT(
    CONCAT(LEFT(subscriber_code,4),'-',RIGHT(subscriber_code,7)),' ',
    IF(last_name IS NULL OR last_name='',company,CONCAT(last_name,', ',first_name)),' - ',
    CONCAT(
    IF(t.street_type_code IS NULL OR t.street_type_code='','',CONCAT(t.street_type_code,' ')),d.street_name,
    IF(s.street_number IS NULL OR s.street_number='','',CONCAT(' ',s.street_number)),
    IF(s.building IS NULL OR s.building='','',CONCAT(' ',s.building)),
    IF(s.floor IS NULL OR s.floor='','',CONCAT(' ',s.floor)),
    IF(s.floor_office IS NULL OR s.floor_office='','',CONCAT(' ',s.floor_office))),' - ',
    m.meter_code
    ) AS everything
    FROM subscribers s
    LEFT JOIN (street_directories d INNER JOIN street_types t ON d.street_type_id=t.id) ON s.street_directory_id=d.id
    LEFT JOIN meters m ON s.meter_id=m.id"
  end

  def down
    execute 'drop view subscriber_filiations'
  end
end
