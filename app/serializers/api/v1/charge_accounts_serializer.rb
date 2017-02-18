class Api::V1::ChargeAccountsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :closed_at, :opened_at,
                  :account_code, :name, :text

  def text
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Account code (Group code & project id & sequential number) => GGGG-PPPNN
    account_code.blank? ? "" : account_code[0..3] + '-' + account_code[4..8]
  end
end
