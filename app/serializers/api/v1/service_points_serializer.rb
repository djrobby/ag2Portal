class Api::V1::ServicePointsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :cadastral_reference, :code, :name, :available_for_contract,
                  :building, :floor, :floor_office, :street_number, :km,
                  :organization_id, :company_id, :office_id, :center_id,
                  :street_directory_id, :zipcode_id, :reading_route_id, :reading_sequence, :reading_variant,
                  :text

  has_one :street_directory
  # has_one :organization
  # has_one :company
  # has_one :office
  # has_one :center
  # has_one :zipcode
  # has_one :reading_route
  # has_many :subscribers

  def text
    code + " " + address_1
  end

  def address_1
    _ret = ""
    if !street_directory.blank?
      if !street_directory.street_type.blank?
        _ret += street_directory.street_type.street_type_code.titleize + ". "
      end
      if !street_directory.street_name.blank?
        _ret += street_directory.street_name + " "
      end
      if !street_number.blank?
        _ret += street_number
      end
      if !building.blank?
        _ret += ", " + building.titleize
      end
      if !floor.blank?
        _ret += ", " + floor_human
      end
      if !floor_office.blank?
        _ret += " " + floor_office
      end
    end
    _ret
  end

  def floor_human
    _ret = floor
    _floor_is_numeric = true if Float(floor) rescue false
    if _floor_is_numeric
      _ret = floor.strip + "\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
    end
    _ret
  end

  def full_code
    # Service point code (Office id & sequential number) => OOOO-NNNNNNN
    code.blank? ? "" : code.length <= 3 ? code : code[0..3] + '-' + code[4..10]
  end
end
