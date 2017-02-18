class Api::V1::ProjectsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :closed_at, :opened_at,
                  :project_code, :name, :text

  def text
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Project code (Company id & project type code & sequential number) => CCC-TTT-NNNNNN
    project_code.blank? ? "" : project_code[0..2] + '-' + project_code[3..5] + '-' + project_code[6..11]
  end
end
