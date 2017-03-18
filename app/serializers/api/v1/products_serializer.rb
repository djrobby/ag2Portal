class Api::V1::ProductsSerializer < ::Api::V1::BaseSerializer
  attributes :id, :active,
                  :product_code, :main_description, :text

  def text
    full_name = full_code
    if !main_description.blank?
      full_name += " " + main_description[0,40]
    end
    full_name
  end

  def full_code
    # Product code (Family code & sequential number) => FFFF-NNNNNN
    product_code.blank? ? "" : product_code[0..3] + '-' + product_code[4..9]
  end
end
