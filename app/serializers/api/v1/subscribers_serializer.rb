class Api::V1::SubscribersSerializer < ::Api::V1::BaseSerializer
  attributes :id, :active, :fiscal_id,
                  :subscriber_code, :first_name, :last_name, :company, :text

  def text
    full_name_or_company_and_code
  end

  def full_name
    full_name = ""
    if !company.blank?
      full_name = company
    else
      if !self.last_name.blank?
        full_name += self.last_name
      end
      if !self.first_name.blank?
        full_name += ", " + self.first_name
      end
      full_name[0,40]
    end
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
    # Subscriber code (Office id & sequential number) => OOOO-NNNNNNN
    subscriber_code.blank? ? "" : subscriber_code[0..3] + '-' + subscriber_code[4..10]
  end
end
