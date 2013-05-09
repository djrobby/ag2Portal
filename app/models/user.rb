class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :role_ids
  # attr_accessible :title, :body
  validates :name,  :presence => true

  after_create :assign_default_role

  has_one :worker
  def to_label
    "#{name} (#{email})"
  end

  def assign_default_role
    add_role(:guest) if self.roles.blank?
  end
end
