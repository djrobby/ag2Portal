class Department < ActiveRecord::Base
  attr_accessible :name, :code,
                  :created_by, :updated_by

  has_paper_trail

  validates :name,  :presence => true
  validates :code,  :presence => true,
                    :length => { :in => 2..5 }

  before_validation :fields_to_uppercase

  has_many :workers
  has_many :corp_contacts
  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def to_label
    "#{name} (#{code})"
  end
end
