class Api::V1::StoresSerializer < ::Api::V1::BaseSerializer
  attributes :id, :name, :text

  def text
    "#{name}"
  end
end
