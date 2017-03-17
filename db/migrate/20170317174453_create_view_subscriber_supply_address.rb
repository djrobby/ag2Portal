class CreateViewSubscriberSupplyAddress < ActiveRecord::Migration
  def up
    execute "create view subscriber_supply_addresses as
    SELECT s.id AS subscriber_id,
    CONCAT(
    IF(t.street_type_code IS NULL OR t.street_type_code='','',CONCAT(t.street_type_code,' ')),d.street_name,
    IF(s.street_number IS NULL OR s.street_number='','',CONCAT(' ',s.street_number)),
    IF(s.building IS NULL OR s.building='','',CONCAT(' ',s.building)),
    IF(s.floor IS NULL OR s.floor='','',CONCAT(' ',s.floor)),
    IF(s.floor_office IS NULL OR s.floor_office='','',CONCAT(' ',s.floor_office))
    ) AS supply_address
    FROM subscribers s
    LEFT JOIN (street_directories d INNER JOIN street_types t ON d.street_type_id=t.id) ON s.street_directory_id=d.id"
  end

  def down
    execute 'drop view subscriber_supply_addresses'
  end
end
