class CorpContact < ActiveRecord::Base
  belongs_to :company
  belongs_to :office
  belongs_to :department
  attr_accessible :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email,
                  :first_name, :last_name, :position, :company_id, :office_id, :department_id, :avatar,
                  :worker_id, :worker_count,
                  :created_by, :updated_by
  has_attached_file :avatar, :styles => { :medium => "96x96>", :small => "64x64>" }, :default_url => "/images/missing/:style/user.png"

  has_paper_trail

  validates :first_name,  :presence => true,
                          :length => { :minimum => 2 }
  validates :last_name,   :presence => true,
                          :length => { :minimum => 2 }
  validates :company,     :presence => true
  validates :office,      :presence => true
  validates :email,       :presence => true

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
    if !self.worker_count.blank? && self.worker_count > 1
      full_name_and_count += " (" + self.worker_count.to_s + ")"
    end
    full_name_and_count
  end

  searchable do
    text :first_name, :last_name, :corp_cellular_long, :corp_cellular_short, :corp_extension, :corp_phone, :email
    string :last_name
    string :first_name
  end
end
