class Worker < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
  belongs_to :office
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  attr_accessible :building, :cellular, :email, :ending_at, :first_name,
                  :fiscal_id, :floor, :floor_office, :last_name, :phone,
                  :starting_at, :street_name, :street_number, :worker_code,
                  :user_id, :company_id, :office_id, :street_type_id,
                  :zipcode_id, :town_id, :province_id, :avatar
  has_attached_file :avatar, :styles => { :medium => "96x96>", :small => "64x64>" }, :default_url => "/images/missing/:style/user.png"

  validates :first_name,      :presence => true,
                              :length => { :minimum => 2 }
  validates :last_name,       :presence => true,
                              :length => { :minimum => 2 }
  validates :worker_code,     :presence => true,
                              :length => { :minimum => 5 },
                              :uniqueness => true
  validates :fiscal_id,       :presence => true,
                              :length => { :minimum => 9 },
                              :uniqueness => true
  validates :user_id,         :presence => true
  validates :company_id,      :presence => true
  validates :office_id,       :presence => true
  validates :starting_at,     :presence => true
  validates :street_type_id,  :presence => true
  validates :zipcode_id,      :presence => true
  validates :town_id,         :presence => true
  validates :province_id,     :presence => true

  before_validation :fields_to_uppercase
  def fields_to_uppercase
    self[:fiscal_id].upcase!
    self[:worker_code].upcase!
  end
end
