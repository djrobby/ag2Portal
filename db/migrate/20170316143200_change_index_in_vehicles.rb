class ChangeIndexInVehicles < ActiveRecord::Migration
  def change
    remove_index :vehicles, name: 'index_vehicles_on_organization_and_registration'
    remove_index :tools, name: 'index_tools_on_organization_and_serial'

    add_index :vehicles,
              [:organization_id, :company_id, :office_id, :registration],
              unique: true, name: 'index_vehicles_on_organization_and_registration'
    add_index :tools,
              [:organization_id, :company_id, :office_id, :serial_no],
              unique: true, name: 'index_tools_on_organization_and_serial'
  end
end
