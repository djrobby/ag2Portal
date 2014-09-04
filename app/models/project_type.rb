class ProjectType < ActiveRecord::Base
  attr_accessible :code, :name

  has_many :projects

  validates :code,  :presence => true,
                    :length => { :is => 3 },
                    :format => { with: /\A[a-zA-Z]+\z/, message: :code_invalid },
                    :uniqueness => true
  validates :name,  :presence => true

  before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ''
    if !self.code.blank?
      full_name += self.code[0,3]
    end
    if !self.name.blank?
      full_name += ": " + self.name[0,30]
    end
    full_name
  end
end
