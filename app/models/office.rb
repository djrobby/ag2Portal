class Office < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_offices
  belongs_to :company
  belongs_to :province
  belongs_to :town
  belongs_to :zipcode
  belongs_to :street_type

  attr_accessible :name, :company_id, :office_code,
                  :street_type_id, :street_name, :street_number, :building, :floor, :floor_office,
                  :zipcode_id, :town_id, :province_id, :phone, :fax, :cellular, :email,
                  :created_by, :updated_by, :nomina_id, :max_order_total, :max_order_price

  has_many :workers
  has_many :worker_items
  has_many :corp_contacts, :order => 'last_name, first_name'
  has_many :tickets
  has_many :projects

  has_paper_trail

  validates :name,         :presence => true
  validates :company,      :presence => true
  validates :office_code,  :presence => true,
                           :length => { :minimum => 5 },
                           :uniqueness => true
  validates :street_type,  :presence => true
  validates :zipcode,      :presence => true
  validates :town,         :presence => true
  validates :province,     :presence => true

  before_destroy :check_for_dependent_records

  def to_label
    "#{name} (#{company.name})"
  end

  private

  def check_for_dependent_records
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_workers'))
      return false
    end
    # Check for worker items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_workers'))
      return false
    end
    # Check for corp contacts
    if corp_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_contacts'))
      return false
    end
    # Check for projects
    if projects.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_projects'))
      return false
    end
    # Check for tickets
    if tickets.count > 0
      errors.add(:base, I18n.t('activerecord.models.office.check_for_tickets'))
      return false
    end
  end
end
