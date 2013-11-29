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
  has_attached_file :avatar, :styles => { :medium => "96x96>", :small => "64x64>" }, :default_url => "/images/missing/:style/user.png"

  has_paper_trail

  validates :first_name,                :presence => true,
                                        :length => { :minimum => 2 }
  validates :last_name,                 :presence => true,
                                        :length => { :minimum => 2 }
  validates :worker_code,               :presence => true,
                                        :length => { :minimum => 5 }
                                        # should :uniqueness => true
  validates :fiscal_id,                 :presence => true,
                                        :length => { :minimum => 9 }
                                        # should :uniqueness => true
  validates :user_id,                   :presence => true
  validates :company_id,                :presence => true
  validates :office_id,                 :presence => true
  validates :street_type_id,            :presence => true
  validates :zipcode_id,                :presence => true
  validates :town_id,                   :presence => true
  validates :province_id,               :presence => true
  validates :professional_group_id,     :presence => true
  validates :collective_agreement_id,   :presence => true
  validates :degree_type_id,            :presence => true
  validates :contract_type_id,          :presence => true
  validates :worker_type_id,            :presence => true
  validates :starting_at,               :presence => true
  validates :issue_starting_at,         :presence => true
  validates :affiliation_id,            :presence => true
                                        # should :uniqueness => true
  validates :contribution_account_code, :presence => true

  before_validation :fields_to_uppercase

  has_many :time_records
  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
    if !self.worker_code.blank?
      self[:worker_code].upcase!
    end
  end

  def to_label
    "#{last_name}, #{first_name}"
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

  def total_cost
    gross_salary + variable_salary + social_security_cost
  end

  def age
    (Date.current - borned_on).round / 365
  end
  
  def years_worked
    if ending_at.blank?
      (Date.current - issue_starting_at).round / 365
    else
      (ending_at - issue_starting_at).round / 365
    end
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
    text :worker_code, :first_name, :last_name, :fiscal_id, :affiliation_id, :contribution_account_code,
         :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email
    integer :company_id
    integer :office_id
    integer :id
    string :worker_code
  end
end
