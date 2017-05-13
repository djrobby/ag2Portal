class Api::V1::MetersSerializer < ::Api::V1::BaseSerializer
  attributes :id, :expiry_date, :first_installation_date, :last_withdrawal_date, :manufacturing_date, :manufacturing_year, :purchase_date,
                  :meter_code, :text

  has_one :meter_model
  has_one :caliber

  def text
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !meter_code.blank?
      full_name += meter_code
    end
    if !meter_model.blank?
      full_name += " " + meter_model.full_name
    end
    if !caliber.blank?
      full_name += " " + caliber.caliber.to_s
    end
    full_name
  end
end
