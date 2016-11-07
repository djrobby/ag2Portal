class Formality < ActiveRecord::Base
  belongs_to :formality_type
  attr_accessible :code, :name
end
