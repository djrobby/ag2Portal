class Company < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_companies
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type
  belongs_to :organization
  attr_accessible :fiscal_id, :name,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email, :logo,
                  :invoice_code, :invoice_header, :invoice_footer, :invoice_left_margin,
                  :created_by, :updated_by, :organization_id, :hd_email
  has_attached_file :logo, :styles => { :original => "160x160>", :medium => "120x120>", :small => "80x80>" }, :default_url => "/images/missing/:style/company.png"

  has_many :offices
  has_many :workers
  has_many :worker_items
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :projects

  has_paper_trail

  validates :name,         :presence => true
  validates :fiscal_id,    :presence => true,
                           :length => { :minimum => 8 },
                           :uniqueness => { :scope => :organization_id }
  validates :street_type,  :presence => true
  validates :zipcode,      :presence => true
  validates :town,         :presence => true
  validates :province,     :presence => true
  validates :invoice_code, :presence => true
  validates :organization, :presence => true

  validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.invoice_code.blank?
      self[:invoice_code].upcase!
    end
  end

  private

  def check_for_dependent_records
    # Check for offices
    if offices.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_offices'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_workers'))
      return false
    end
    # Check for corp contacts
    if corp_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_contacts'))
      return false
    end
    # Check for projects
    if projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.company.check_for_projects'))
      return false
    end
  end
end
