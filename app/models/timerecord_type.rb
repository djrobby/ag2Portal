class TimerecordType < ActiveRecord::Base
  attr_accessible :name,
                  :created_by, :updated_by

  has_paper_trail

  validates :name,  :presence => true,
                    :length => { :is => 1},
                    :uniqueness => true

  before_validation :fields_to_uppercase

  has_many :time_records
  def fields_to_uppercase
    if !self.name.blank?
      self[:name].upcase!
    end
  end
end
