class ProductFamilies < ActiveRecord::Base
  attr_accessible :family_code, :max_orders_count, :max_orders_sum, :name

  has_paper_trail

  validates :name,        :presence => true
  validates :family_code, :presence => true,
                          :length => { :in => 3..5 },
                          :uniqueness => true

  before_validation :fields_to_uppercase
  def fields_to_uppercase
    if !self.family_code.blank?
      self[:family_code].upcase!
    end
  end

  def to_label
    "#{name} (#{family_code})"
  end
end
