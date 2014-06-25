class Ability
  include CanCan::Ability
  def initialize(user)
    # user ||= User.new # guest user (not logged in)
    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :create, :update, :to => :write
    alias_action :create, :update, :destroy, :to => :cud

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

    # Users can read guides
    cannot :cud, Guide
    cannot :cud, Subguide

    # Users can manage attachments
    can :manage, Attachment
    
    #
    # Users according to their roles
    # IMPORTANT!
    # Update method 'assign_default_role_and_send_email' in users model for each new role added
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
      can :crud, Entity
      can :crud, EntityType
      can :crud, TaxType
      can :crud, Department
      can :crud, Area
    elsif user.has_role? :ag2Admin_Guest
      can :read, Company
      can :read, Country
      can :read, Office
      can :read, Province
      can :read, Region
      can :read, StreetType
      can :read, Town
      can :read, Zipcode
      can :read, Entity
      can :read, EntityType
      can :read, TaxType
      can :read, Department
      can :read, Area
    elsif user.has_role? :ag2Admin_Banned
      cannot :manage, Company
      cannot :manage, Country
      cannot :manage, Office
      cannot :manage, Province
      cannot :manage, Region
      cannot :manage, StreetType
      cannot :manage, Town
      cannot :manage, Zipcode
      cannot :manage, Entity
      cannot :manage, EntityType
      cannot :manage, TaxType
      cannot :manage, Department
      cannot :manage, Area
    end
    # ag2Directory
    if user.has_role? :ag2Directory_User
      can :crud, CorpContact
      can :search, CorpContact
      can :crud, SharedContactType
      can :crud, SharedContact
    elsif user.has_role? :ag2Directory_Guest
      can :read, CorpContact
      can :search, CorpContact
      can :read, SharedContactType
      can :read, SharedContact
    elsif user.has_role? :ag2Directory_Banned
      cannot :manage, CorpContact
      cannot :manage, SharedContactType
      cannot :manage, SharedContact
    end
    # ag2Finance (ag2Analytics)
    if user.has_role? :ag2Analytics_User
    elsif user.has_role? :ag2Analytics_Guest
    elsif user.has_role? :ag2Analytics_Banned
    end
    # ag2Gest
    if user.has_role? :ag2Gest_User
      can :crud, Client
    elsif user.has_role? :ag2Gest_Guest
      can :read, Client
    elsif user.has_role? :ag2Gest_Banned
      cannot :manage, Client
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
    # ag2Human
    if user.has_role? :ag2Human_User
      can :crud, CollectiveAgreement
      can :crud, ContractType
      can :crud, DegreeType
      can :crud, Department
      can :crud, Insurance
      can :crud, ProfessionalGroup
      can :crud, SalaryConcept
      can :crud, TimeRecord
      can :crud, TimerecordCode
      can :crud, TimerecordType
      can :crud, WorkerType
      can :crud, Worker
      can :crud, WorkerItem
      can :crud, WorkerSalary
      can :crud, WorkerSalaryItem
    elsif user.has_role? :ag2Human_Guest
      can :read, CollectiveAgreement
      can :read, ContractType
      can :read, DegreeType
      can :read, Department
      can :read, Insurance
      can :read, ProfessionalGroup
      can :read, SalaryConcept
      can :read, TimeRecord
      can :read, TimerecordCode
      can :read, TimerecordType
      can :read, WorkerType
      can :read, Worker
      can :read, WorkerItem
      can :read, WorkerSalary
      can :read, WorkerSalaryItem
    elsif user.has_role? :ag2Human_Banned
      cannot :manage, CollectiveAgreement
      cannot :manage, ContractType
      cannot :manage, DegreeType
      cannot :manage, Department
      cannot :manage, Insurance
      cannot :manage, ProfessionalGroup
      cannot :manage, SalaryConcept
      cannot :manage, TimeRecord
      cannot :manage, TimerecordCode
      cannot :manage, TimerecordType
      cannot :manage, WorkerType
      cannot :manage, Worker
      cannot :manage, WorkerItem
      cannot :manage, WorkerSalary
      cannot :manage, WorkerSalaryItem
    end
    # ag2Purchase
    if user.has_role? :ag2Purchase_User
      can :crud, Activity
      can :crud, PaymentMethod
      can :crud, Supplier
      can :crud, SupplierContact
      can :crud, PurchasePrice
      can :crud, OrderStatus
      can :crud, PurchaseOrder
      can :crud, PurchaseOrderItem
    elsif user.has_role? :ag2Purchase_Guest
      can :read, Activity
      can :read, PaymentMethod
      can :read, Supplier
      can :read, SupplierContact
      can :read, PurchasePrice
      can :read, OrderStatus
      can :read, PurchaseOrder
      can :read, PurchaseOrderItem
    elsif user.has_role? :ag2Purchase_Banned
      cannot :manage, Activity
      cannot :manage, PaymentMethod
      cannot :manage, Supplier
      cannot :manage, SupplierContact
      cannot :manage, PurchasePrice
      cannot :manage, OrderStatus
      cannot :manage, PurchaseOrder
      cannot :manage, PurchaseOrderItem
    end
    # ag2Products (ag2Logistics)
    if user.has_role? :ag2Logistics_User
      can :crud, Manufacturer
      can :crud, Measure
      can :crud, ProductFamily
      can :crud, ProductType
      can :crud, Product
      can :crud, PurchasePrice
      can :crud, Store
      can :crud, Stock
    elsif user.has_role? :ag2Logistics_Guest
      can :read, Manufacturer
      can :read, Measure
      can :read, ProductFamily
      can :read, ProductType
      can :read, Product
      can :read, PurchasePrice
      can :read, Store
      can :read, Stock
    elsif user.has_role? :ag2Logistics_Banned
      cannot :manage, Manufacturer
      cannot :manage, Measure
      cannot :manage, ProductFamily
      cannot :manage, ProductType
      cannot :manage, Product
      cannot :manage, PurchasePrice
      cannot :manage, Store
      cannot :manage, Stock
    end
    # ag2Tech
    if user.has_role? :ag2Tech_User
      can :crud, Project
      can :crud, ChargeAccount
      can :crud, WorkOrderType
      can :crud, WorkOrderLabor
      can :crud, WorkOrderStatus
      can :crud, WorkOrder
      can :crud, WorkOrderItem
    elsif user.has_role? :ag2Tech_Guest
      can :read, Project
      can :read, ChargeAccount
      can :read, WorkOrderType
      can :read, WorkOrderLabor
      can :read, WorkOrderStatus
      can :read, WorkOrder
      can :read, WorkOrderItem
    elsif user.has_role? :ag2Tech_Banned
      cannot :manage, Project
      cannot :manage, ChargeAccount
      cannot :manage, WorkOrderType
      cannot :manage, WorkOrderLabor
      cannot :manage, WorkOrderStatus
      cannot :manage, WorkOrder
      cannot :manage, WorkOrderItem
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
