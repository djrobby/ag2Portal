class Currency < ActiveRecord::Base
  attr_accessible :alphabetic_code, :currency, :minor_unit, :numeric_code
end
