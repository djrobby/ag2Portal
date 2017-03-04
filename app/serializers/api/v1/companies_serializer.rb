class Api::V1::CompaniesSerializer < ::Api::V1::BaseSerializer
  attributes :id, :fiscal_id, :name, :text

  def text
    full_name = ''
    if !fiscal_id.blank?
      full_name += fiscal_id
    end
    if !name.blank?
      full_name += (full_name.blank? ? name : " " + name)
    end
    full_name
  end
end
