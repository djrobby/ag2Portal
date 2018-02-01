class Api::V1::ReadingRoutesSerializer < ::Api::V1::BaseSerializer
  attributes :id, :routing_code, :name, :text

  def text
    "#{full_code} (#{name})"
  end

  def full_code
    routing_code.blank? ? "" : routing_code[0..3] + '-' + routing_code[4..9]
  end
end
