class Organization < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_organizations
  attr_accessible :name, :hd_email

  has_many :companies

  has_paper_trail

  validates :name,  :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.name.blank?
      self[:name].upcase!
    end
  end

  private

  def check_for_dependent_records
    # Check for companies
    if companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_companies'))
      return false
    end
  end
end
