class LedgerAccount < ActiveRecord::Base
  belongs_to :accounting_group
  belongs_to :project
  belongs_to :organization
  attr_accessible :code, :name, :accounting_group_id, :project_id, :organization_id

  has_paper_trail

  validates :code,              :presence => true,
                                :uniqueness => { :scope => :organization_id }
  validates :name,              :presence => true
  validates :accounting_group,  :presence => true
  validates :organization,      :presence => true
  
  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = code.blank? ? "" : code.strip
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end
end
