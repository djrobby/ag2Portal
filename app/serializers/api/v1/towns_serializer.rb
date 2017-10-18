class Api::V1::TownsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :ine_cmun, :ine_dc, :name, :text

  has_one :province

  def text
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !name.blank?
      full_name += name
    end
    if !province.blank?
      full_name += " (" + province.name + ")"
    end
    full_name
  end
end
