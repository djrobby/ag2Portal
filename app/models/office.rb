class Office < ActiveRecord::Base
  belongs_to :company
  attr_accessible :name
end
