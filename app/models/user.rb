class User < ActiveRecord::Base
  rolify
  has_and_belongs_to_many :organizations, :join_table => :users_organizations
  has_and_belongs_to_many :companies, :join_table => :users_companies
  has_and_belongs_to_many :offices, :join_table => :users_offices
  has_and_belongs_to_many :projects, :join_table => :users_projects
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # OmniAuth providers:
  # OpenID
  # :omniauth_providers => [:google_apps]
  # OAuth2
  # :omniauth_providers => [:google_oauth2]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,
                  :created_by, :updated_by, :real_email, :authentication_token
  attr_accessible :role_ids, :organization_ids, :company_ids, :office_ids, :project_ids
  # attr_accessible :title, :body

  has_many :workers # has_one when finished worker_items implementation
  has_one :technician
  has_many :tickets, foreign_key: :created_by
  has_many :cc_tickets, class_name: 'Ticket', foreign_key: :cc_id
  has_many :background_works

  has_paper_trail

  validates :name,  :presence => true

  # Scopes
  scope :by_email, -> { order(:email) }
  scope :by_name, -> { order(:name) }
  #
  scope :belongs_to_organization, -> o { joins(:organizations).where(organizations: { id: o }).by_email }
  scope :g_where, -> w {
    joins("LEFT JOIN users_organizations ON users.id=users_organizations.user_id")
    .joins("LEFT JOIN users_companies ON users.id=users_companies.user_id")
    .joins("LEFT JOIN users_offices ON users.id=users_offices.user_id")
    .where(w)
    .select('users.id, users.name, users.email')
    .by_email
  }

  # Callbacks
  before_save :ensure_authentication_token
  after_create :assign_default_role_and_send_email

  def works_pending
    background_works.where(complete: false)
  end

  def creating_prebills?
    works_pending.any?{|w| w.type_work == "create_prebills"}
  end

  def confirming_prebills?
    works_pending.any?{|w| w.type_work == "confirm_prebills"}
  end

  def wcreating_pending
    works_pending.where(type_work: "create_prebills")
  end

  def wconfirm_pending
    works_pending.where(type_work: "confirm_prebills")
  end

  def prebill_pending?(group_no)
    !background_works.where(complete: false, group_no: group_no).first.blank?
  end

  def to_label
    "#{name} (#{email})"
  end

  def self.domains
    domains = []
    # loop thru existing users
    User.all.each do |u|
      email_domain = u.email.split('@').last  # extract domain from email
      # check if domain already exists
      exists = false
      for i in 0...domains.size
        if email_domain == domains[i]
          exists = true
        end
      end
      if exists == false
        domains = domains << email_domain
      end
    end
    domains
  end

  private

  def assign_default_role_and_send_email
    if self.roles.blank?
      # Assign default roles
      add_role(:ag2Admin_Banned)
      add_role(:ag2Analytics_Banned)
      add_role(:ag2Directory_Guest)
      add_role(:ag2Gest_Banned)
      add_role(:ag2HelpDesk_Banned)
      add_role(:ag2Human_Banned)
      add_role(:ag2Logistics_Banned)
      add_role(:ag2Purchase_Banned)
      add_role(:ag2Tech_Banned)
      add_role(:ag2Config_Banned)
      # Send e-mail to administrator to configure the right roles
      Notifier.user_created(self).deliver
    end
  end

  # OAuth2
  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(:name => data["name"], :email => data["email"], :password => Devise.friendly_token[0,20])
    end
    user
  end

  # OpenID
  def self.find_for_googleapps_oauth(access_token, signed_in_resource=nil)
    data = access_token['info']

    if user = User.where(:email => data['email']).first
    return user
    else #create a user with stub pwd
      User.create!(:email => data['email'], :password => Devise.friendly_token[0,20])
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.googleapps_data'] && session['devise.googleapps_data']['user_info']
        user.email = data['email']
      end
    end
  end
end
