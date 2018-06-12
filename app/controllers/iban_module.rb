require 'iban-tools'

#
# IBAN methods using iban-tools
#
module IbanModule
  # Validate IBAN
  def iban_valid?(iban)
    IBANTools::IBAN.valid?(iban)
  end
end
