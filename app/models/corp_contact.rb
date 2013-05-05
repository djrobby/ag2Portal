class CorpContact < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  belongs_to :department
  attr_accessible :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email,
                  :first_name, :last_name, :position, :company_id, :office_id, :department_id, :avatar,
                  :worker_id
  has_attached_file :avatar, :styles => { :medium => "96x96>", :small => "64x64>" }, :default_url => "/images/missing/:style/user.png"

  validates :first_name,  :presence => true,
                          :length => { :minimum => 2 }
  validates :last_name,   :presence => true,
                          :length => { :minimum => 2 }
  validates :company_id,  :presence => true
  validates :office_id,   :presence => true
  validates :email,       :presence => true

  def full_name
    self.last_name + ", " + self.first_name
  end

  searchable do
    text :first_name, :last_name, :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email
  end
end
