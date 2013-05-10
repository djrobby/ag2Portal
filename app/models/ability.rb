class Ability
  include CanCan::Ability
  def initialize(user)
    # user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :create, :update, :to => :write

    # Not logged-in users can't manage anything
    if user.nil?
      cannot :manage, :all
      return      
    end
    
    # Administrators (administrator role) can manage all
    if user.has_role? :Administrator
      can :manage, :all
      return
    end
    
    # Users can't manage configurations
    cannot :manage, :app
    cannot :manage, :data_import_config
    cannot :manage, :role
    cannot :manage, :site
    cannot :manage, :user
    
    #
    # Users according to their roles
    #
    # ag2Admin
    if user.has_role? :ag2Admin_User
      can :crud, :company
      can :crud, :country
      can :crud, :office
      can :crud, :province
      can :crud, :region
      can :crud, :street_type
      can :crud, :town
      can :crud, :zipcode
    elsif user.has_role? :ag2Admin_Guest
      can :read, :company
      can :read, :country
      can :read, :office
      can :read, :province
      can :read, :region
      can :read, :street_type
      can :read, :town
      can :read, :zipcode
    elsif user.has_role? :ag2Admin_Banned
      can :manage, :company
      can :manage, :country
      can :manage, :office
      can :manage, :province
      can :manage, :region
      can :manage, :street_type
      can :manage, :town
      can :manage, :zipcode
    end

  # Define abilities for the passed in user here. For example:
  #
  #   user ||= User.new # guest user (not logged in)
  #   if user.admin?
  #     can :manage, :all
  #   else
  #     can :read, :all
  #   end
  #
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details:
  # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  #
  # CanCan default actions:
  # :manage (any action, including 7 defaults and customs defined), :
  # and custom actions (methods) added to a controller (ie. :search, :invite, etc)
  # the 7 RESTful actions in Rails: :index, :show, :new, :edit, :create, :update, :destroy
  end
end
