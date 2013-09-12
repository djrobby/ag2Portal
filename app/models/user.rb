class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # OmniAuth providers:
  # OpenID
  # :omniauth_providers => [:google_apps]
  # OAuth2
  # :omniauth_providers => [:google_oauth2]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :omniauth_providers => [:google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me,
                  :created_by, :updated_by
  attr_accessible :role_ids
  # attr_accessible :title, :body

  has_paper_trail

  validates :name,  :presence => true

  after_create :assign_default_role_and_send_email

  has_one :worker
  has_one :technician
  def to_label
    "#{name} (#{email})"
  end

  private

  def assign_default_role_and_send_email
    if self.roles.blank?
      # Assign default roles
      add_role(:ag2Admin_Guest)
      add_role(:ag2Directory_Guest)
      add_role(:ag2Human_Banned)
      add_role(:ag2HelpDesk_Banned)
      add_role(:ag2Purchase_Banned)
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
