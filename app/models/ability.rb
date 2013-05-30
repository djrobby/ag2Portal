class Ability
  include CanCan::Ability
  def initialize(user)
    # user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :delete, :to => :crud
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
    cannot :manage, App
    cannot :manage, DataImportConfig
    cannot :manage, Role
    cannot :manage, Site
    cannot :manage, User
    
    #
    # Users according to their roles
    #
    # ag2Admin
    if user.has_role? :ag2Admin_User
      can :crud, Company
      can :crud, Country
      can :crud, Office
      can :crud, Province
      can :crud, Region
      can :crud, StreetType
      can :crud, Town
      can :crud, Zipcode
    elsif user.has_role? :ag2Admin_Guest
      can :read, Company
      can :read, Country
      can :read, Office
      can :read, Province
      can :read, Region
      can :read, StreetType
      can :read, Town
      can :read, Zipcode
    elsif user.has_role? :ag2Admin_Banned
      cannot :manage, Company
      cannot :manage, Country
      cannot :manage, Office
      cannot :manage, Province
      cannot :manage, Region
      cannot :manage, StreetType
      cannot :manage, Town
      cannot :manage, Zipcode
    end
    # ag2Directory
    if user.has_role? :ag2Directory_User
      can :crud, CorpContact
      can :crud, SharedContactType
      can :crud, SharedContact
    elsif user.has_role? :ag2Directory_Guest
      can :read, CorpContact
      can :read, SharedContactType
      can :read, SharedContact
    elsif user.has_role? :ag2Directory_Banned
      cannot :manage, CorpContact
      cannot :manage, SharedContactType
      cannot :manage, SharedContact
    end
    # ag2Human
    if user.has_role? :ag2Human_User
      can :crud, CollectiveAgreement
      can :crud, ContractType
      can :crud, DegreeType
      can :crud, Department
      can :crud, ProfessionalGroup
      can :crud, TimeRecord
      can :crud, TimerecordCode
      can :crud, TimerecordType
      can :crud, WorkerType
      can :crud, Worker
    elsif user.has_role? :ag2Human_Guest
      can :read, CollectiveAgreement
      can :read, ContractType
      can :read, DegreeType
      can :read, Department
      can :read, ProfessionalGroup
      can :read, TimeRecord
      can :read, TimerecordCode
      can :read, TimerecordType
      can :read, WorkerType
      can :read, Worker
    elsif user.has_role? :ag2Human_Banned
      cannot :manage, CollectiveAgreement
      cannot :manage, ContractType
      cannot :manage, DegreeType
      cannot :manage, Department
      cannot :manage, ProfessionalGroup
      cannot :manage, TimeRecord
      cannot :manage, TimerecordCode
      cannot :manage, TimerecordType
      cannot :manage, WorkerType
      cannot :manage, Worker
    end
    # ag2HelpDesk
    if user.has_role? :ag2HelpDesk_User
      can :crud, Technician
      can :crud, TicketCategory
      can :crud, TicketPriority
      can :crud, TicketStatus
      can :crud, Ticket
    elsif user.has_role? :ag2HelpDesk_Guest
      can :read, Technician
      can :read, TicketCategory
      can :read, TicketPriority
      can :read, TicketStatus
      can :create, Ticket
      can :read, Ticket
    elsif user.has_role? :ag2HelpDesk_Banned
      cannot :manage, Technician
      cannot :manage, TicketCategory
      cannot :manage, TicketPriority
      cannot :manage, TicketStatus
      can :create, Ticket
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
