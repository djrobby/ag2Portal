class Api::V1::ZipcodesSerializer < ::Api::V1::BaseSerializer
  attributes :id, :zipcode, :text

  has_one :town
  has_one :province

  def text
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !zipcode.blank?
      full_name += zipcode
    end
    if !town.blank?
      full_name += " - " + town.name
    end
    if !province.blank?
      full_name += " (" + province.name + ")"
    end
    full_name
  end
end
