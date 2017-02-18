class Api::V1::ClientsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :active, :fiscal_id,
                  :client_code, :first_name, :last_name, :company, :text

  def text
    full_name_or_company_and_code
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name[0,40]
  end

  def full_name_or_company
    full_name_or_company = ""
    if !self.last_name.blank? || !self.first_name.blank?
      full_name_or_company = full_name
    else
      full_name_or_company = company[0,40] if !company.blank?
    end
    full_name_or_company
  end

  def full_name_or_company_and_code
    full_code + " " + full_name_or_company
  end

  def full_code
    # Client code (Organization id & sequential number) => OOOO-NNNNNNN
    client_code.blank? ? "" : client_code[0..3] + '-' + client_code[4..10]
  end
end
