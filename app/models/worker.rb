class Worker < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :office
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :collective_agreement
  belongs_to :contract_type
  belongs_to :degree_type
  belongs_to :professional_group
  belongs_to :worker_type
  belongs_to :department
  belongs_to :sex
  belongs_to :insurance
  attr_accessible :building, :own_cellular, :email, :ending_at, :first_name,
                  :fiscal_id, :floor, :floor_office, :last_name, :own_phone,
                  :starting_at, :street_name, :street_number, :worker_code,
                  :user_id, :company_id, :office_id, :street_type_id,
                  :zipcode_id, :town_id, :province_id, :avatar,
                  :professional_group_id, :collective_agreement_id,
                  :degree_type_id, :contract_type_id, :worker_type_id,
                  :borned_on, :issue_starting_at, :affiliation_id,
                  :contribution_account_code, :position, :corp_phone,
                  :corp_cellular_long, :corp_cellular_short, :corp_extension,
                  :department_id, :nomina_id, :gross_salary, :variable_salary,
                  :created_by, :updated_by, :remarks, :sex_id, :insurance_id,
                  :social_security_cost, :education
  has_attached_file :avatar, :styles => { :original => "128x128>", :medium => "96x96>", :small => "64x64>" }, :default_url => "/images/missing/:style/user.png"

  has_many :time_records
  has_many :worker_items
  has_many :worker_salaries, :through => :worker_items
  has_many :work_order_workers

  has_paper_trail

  validates :first_name,                :presence => true,
                                        :length => { :minimum => 2 }
  validates :last_name,                 :presence => true,
                                        :length => { :minimum => 2 }
  validates :worker_code,               :presence => true,
                                        :length => { :minimum => 5 }
                                        # should :uniqueness => true
  validates :fiscal_id,                 :presence => true,
                                        :length => { :minimum => 9 },
                                        :uniqueness => true
  validates :user,                      :presence => true
  validates :street_type,               :presence => true
  validates :zipcode,                   :presence => true
  validates :town,                      :presence => true
  validates :province,                  :presence => true
  validates :degree_type,               :presence => true
  validates :worker_type,               :presence => true
  validates :affiliation_id,            :presence => true
                                        # should :uniqueness => true
  #validates :sex,                       :presence => true

  # Deactivated because in WorkerItem:
  #validates :professional_group,        :presence => true
  #validates :collective_agreement,      :presence => true
  #validates :company,                   :presence => true
  #validates :office,                    :presence => true
  #validates :contribution_account_code, :presence => true
  #validates :department,                :presence => true
  #validates :contract_type,             :presence => true
  #validates :starting_at,               :presence => true
  #validates :issue_starting_at,         :presence => true

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.worker_code.blank?
      self[:worker_code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name
  end

  def full_name_and_count
    full_name_and_count = ""
    if !self.last_name.blank?
      full_name_and_count += self.last_name
    end
    if !self.first_name.blank?
      full_name_and_count += ", " + self.first_name
    end
    if worker_count > 1
      full_name_and_count += " (" + worker_count.to_s + ")"
    end
    full_name_and_count
  end

  def worker_count
    worker_items.count
  end
  
  def age
    (Date.current - borned_on).round / 365
  end
  
  #
  # Records navigator
  #
  def to_first
    Worker.order("worker_code, id").first
  end

  def to_prev
    Worker.where("worker_code < ?", worker_code).order("worker_code, id").last
  end

  def to_next
    Worker.where("worker_code > ?", worker_code).order("worker_code, id").first
  end

  def to_last
    Worker.order("worker_code, id").last
  end

  def duplicate
    Worker.where("worker_code = ?", worker_code).count
  end

  def to_duplicate_prev
    Worker.where("worker_code = ? and id < ?", worker_code, id).order("worker_code, id").last
  end

  def to_duplicate_next
    Worker.where("worker_code = ? and id > ?", worker_code, id).order("worker_code, id").first
  end
  
  searchable do
    text :worker_code, :first_name, :last_name, :fiscal_id, :affiliation_id,
         :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email
    integer :id
    string :worker_code
    string :last_name
  end

  private

  def check_for_dependent_records
    # Check for items
    if worker_items.count > 0
      errors.add(:base, I18n.t('activerecord.models.worker.check_for_items'))
      return false
    end
    # Check for work orders
    if work_order_workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.worker.check_for_work_orders'))
      return false
    end
  end
end
