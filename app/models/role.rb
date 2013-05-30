class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,
                  :created_by, :updated_by

  has_paper_trail

  validates :name, :presence => true

  scopify

  before_destroy :check_for_users
  before_update :check_for_users

  private
  def check_for_users
    if users.count > 0
      errors.add(:base, I18n.t('activerecord.models.role.check_for_users'))
      return false
    end
  end
end
