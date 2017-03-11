class Api::V1::SuppliersSerializer < ::Api::V1::BaseSerializer
  attributes :id, :active, :fiscal_id,
                  :supplier_code, :name, :text

  def text
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  def full_code
    # Supplier code (Organization id & Main activity & sequential number) => OOOO-AAAA-NNNNNN
    supplier_code.blank? || supplier_code == "$ERR" ? "" : supplier_code[0..3] + '-' + supplier_code[4..7] + '-' + supplier_code[8..13]
  end
end
