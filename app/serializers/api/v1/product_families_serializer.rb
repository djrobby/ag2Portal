class Api::V1::ProductFamiliesSerializer < ::Api::V1::BaseSerializer
  attributes :id, :family_code, :name, :text

  def text
    full_name = ''
    if !family_code.blank?
      full_name = self.family_code
    end
    if !name.blank?
      full_name += " " + name[0,40]
    end
    full_name
  end
end
