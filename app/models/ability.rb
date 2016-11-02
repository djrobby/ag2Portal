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
    cannot :manage, Notification
    cannot :manage, Organization
    cannot :manage, Role
    cannot :manage, Site
    cannot :manage, User

    # Users can read guides
    cannot :cud, Guide
    cannot :cud, Subguide

    # Users can manage attachments
    can :manage, Attachment

    # Product managers
    if user.has_role? :Product_Manager
      can :crud, ProductFamily
      can :crud, ProductType
      can :crud, Product
      can :crud, PurchasePrice
      can :crud, ProductCompanyPrice
      can :crud, Stock
    end

    #
    # Users according to their roles
    # IMPORTANT!
    # Update method 'assign_default_role_and_send_email' in users model for each new role added
    #
    # ag2Admin
    if user.has_role? :ag2Admin_User
      can :crud, Bank
      can :crud, BankOffice
      can :crud, BankAccountClass
      can :crud, Company
      #can :crud, CompanyNotification
      can :read, CompanyNotification
      can :crud, Country
      can :crud, Office
      #can :crud, OfficeNotification
      can :read, OfficeNotification
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
      can :crud, AccountingGroup
      can :crud, LedgerAccount
      can :crud, PaymentMethod
      can :crud, Zone
      can :read, ZoneNotification
    elsif user.has_role? :ag2Admin_Guest
      can :read, Bank
      can :read, BankOffice
      can :read, BankAccountClass
      can :read, Company
      can :read, CompanyNotification
      can :read, Country
      can :read, Office
      can :read, OfficeNotification
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
      can :read, AccountingGroup
      can :read, LedgerAccount
      can :read, PaymentMethod
      can :read, Zone
      can :read, ZoneNotification
    elsif user.has_role? :ag2Admin_Banned
      cannot :manage, Bank
      cannot :manage, BankOffice
      cannot :manage, BankAccountClass
      cannot :manage, Company
      cannot :manage, CompanyNotification
      cannot :manage, Country
      cannot :manage, Office
      cannot :manage, OfficeNotification
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
      cannot :manage, AccountingGroup
      cannot :manage, LedgerAccount
      cannot :manage, PaymentMethod
      cannot :manage, Zone
      cannot :manage, ZoneNotification
    end
    # ag2Config
    if user.has_role? :ag2Config_User
      can :manage, App
      can :manage, DataImportConfig
      can :manage, Organization
      can :manage, Role
      can :manage, Site
      can :manage, User
      can :manage, Guide
      can :manage, Subguide
      can :manage, Notification
    elsif user.has_role? :ag2Config_Guest
      can :read, App
      can :read, DataImportConfig
      can :read, Organization
      can :read, Role
      can :read, Site
      can :read, User
      can :read, Guide
      can :read, Subguide
      can :read, Notification
    elsif user.has_role? :ag2Config_Banned
      cannot :manage, App
      cannot :manage, DataImportConfig
      cannot :manage, Organization
      cannot :manage, Role
      cannot :manage, Site
      cannot :manage, User
      cannot :manage, Guide
      cannot :manage, Subguide
      cannot :manage, Notification
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
      can :crud, PaymentMethod
      can :crud, SaleOffer
      can :crud, SaleOfferItem
      can :crud, SaleOfferStatus
      can :crud, Subscriber
      can :crud, StreetDirectory
      can :crud, Center
      can :crud, SubscriberAnnotation
      can :crud, SubscriberAnnotationClass
      can :crud, WaterConnection
      can :crud, WaterConnectionContract
      can :crud, WaterConnectionType
      can :crud, WaterSupplyContract
      can :crud, ServicePoint
      can :crud, ServicePointLocation
      can :crud, ServicePointPurpose
      can :crud, ServicePointType
      can :crud, Meter
      can :crud, MeterBrand
      can :crud, MeterDetail
      can :crud, MeterLocation
      can :crud, MeterModel
      can :crud, MeterOwner
      can :crud, MeterType
      can :crud, Caliber
      can :crud, BillingFrequency
      can :crud, BillingPeriod
      can :crud, Reading
      can :crud, ReadingIncidence
      can :crud, ReadingIncidenceType
      can :crud, ReadingRoute
      can :crud, ReadingType
      can :crud, PreReading
      can :crud, PreReadingIncidence
      can :crud, Tariff
      can :crud, TariffScheme
      can :crud, TariffType
      can :crud, BillableConcept
      can :crud, BillableItem
      can :crud, Caliber
      can :crud, BillingFrequency
      can :crud, BillingPeriod
      can :crud, Regulation
      can :crud, RegulationType
      can :crud, ContractingRequest
      can :crud, ContractingRequestDocument
      can :crud, ContractingRequestDocumentType
      can :crud, ContractingRequestStatus
      can :crud, ContractingRequestType
      can :crud, Invoice
      can :crud, InvoiceItem
      can :crud, InvoiceOperation
      can :crud, InvoiceStatus
      can :crud, InvoiceType
      can :crud, Bill
      can :crud, PreBill
      can :crud, PreInvoice
      can :crud, PreInvoiceItem
      can :crud, ClientPayment
      can :crud, Instalment
      can :crud, InstalmentPlan
      can :crud, ClientBankAccount
    elsif user.has_role? :ag2Gest_Guest
      can :read, Client
      can :read, PaymentMethod
      can :read, SaleOffer
      can :read, SaleOfferItem
      can :read, SaleOfferStatus
      can :read, Subscriber
      can :read, StreetDirectory
      can :read, Center
      can :read, SubscriberAnnotation
      can :read, SubscriberAnnotationClass
      can :read, WaterConnection
      can :read, WaterConnectionContract
      can :read, WaterConnectionType
      can :read, WaterSupplyContract
      can :read, ServicePoint
      can :read, ServicePointLocation
      can :read, ServicePointPurpose
      can :read, ServicePointType
      can :read, Meter
      can :read, MeterBrand
      can :read, MeterDetail
      can :read, MeterLocation
      can :read, MeterModel
      can :read, MeterOwner
      can :read, MeterType
      can :read, Caliber
      can :read, BillingFrequency
      can :read, BillingPeriod
      can :read, Reading
      can :read, ReadingIncidence
      can :read, ReadingIncidenceType
      can :read, ReadingRoute
      can :read, ReadingType
      can :read, PreReading
      can :read, PreReadingIncidence
      can :read, Tariff
      can :read, TariffScheme
      can :read, TariffType
      can :read, BillableConcept
      can :read, BillableItem
      can :read, Caliber
      can :read, BillingFrequency
      can :read, BillingPeriod
      can :read, Regulation
      can :read, RegulationType
      can :read, ContractingRequest
      can :read, ContractingRequestDocument
      can :read, ContractingRequestDocumentType
      can :read, ContractingRequestStatus
      can :read, ContractingRequestType
      can :read, Invoice
      can :read, InvoiceItem
      can :read, InvoiceOperation
      can :read, InvoiceStatus
      can :read, InvoiceType
      can :read, Bill
      can :read, PreBill
      can :read, PreInvoice
      can :read, PreInvoiceItem
      can :read, ClientPayment
      can :read, Instalment
      can :read, InstalmentPlan
      can :read, ClientBankAccount
    elsif user.has_role? :ag2Gest_Banned
      cannot :manage, Client
      cannot :manage, PaymentMethod
      cannot :manage, Client
      cannot :manage, PaymentMethod
      cannot :manage, SaleOffer
      cannot :manage, SaleOfferItem
      cannot :manage, SaleOfferStatus
      cannot :manage, Subscriber
      cannot :manage, StreetDirectory
      cannot :manage, Center
      cannot :manage, SubscriberAnnotation
      cannot :manage, SubscriberAnnotationClass
      cannot :manage, WaterConnection
      cannot :manage, WaterConnectionContract
      cannot :manage, WaterConnectionType
      cannot :manage, WaterSupplyContract
      cannot :manage, ServicePoint
      cannot :manage, ServicePointLocation
      cannot :manage, ServicePointPurpose
      cannot :manage, ServicePointType
      cannot :manage, Meter
      cannot :manage, MeterBrand
      cannot :manage, MeterDetail
      cannot :manage, MeterLocation
      cannot :manage, MeterModel
      cannot :manage, MeterOwner
      cannot :manage, MeterType
      cannot :manage, Caliber
      cannot :manage, BillingFrequency
      cannot :manage, BillingPeriod
      cannot :manage, Reading
      cannot :manage, ReadingIncidence
      cannot :manage, ReadingIncidenceType
      cannot :manage, ReadingRoute
      cannot :manage, ReadingType
      cannot :manage, PreReading
      cannot :manage, PreReadingIncidence
      cannot :manage, Tariff
      cannot :manage, TariffScheme
      cannot :manage, TariffType
      cannot :manage, BillableConcept
      cannot :manage, BillableItem
      cannot :manage, Caliber
      cannot :manage, BillingFrequency
      cannot :manage, BillingPeriod
      cannot :manage, Regulation
      cannot :manage, RegulationType
      cannot :manage, ContractingRequest
      cannot :manage, ContractingRequestDocument
      cannot :manage, ContractingRequestDocumentType
      cannot :manage, ContractingRequestStatus
      cannot :manage, ContractingRequestType
      cannot :manage, Invoice
      cannot :manage, InvoiceItem
      cannot :manage, InvoiceOperation
      cannot :manage, InvoiceStatus
      cannot :manage, InvoiceType
      cannot :manage, Bill
      cannot :manage, PreBill
      cannot :manage, PreInvoice
      cannot :manage, PreInvoiceItem
      cannot :manage, ClientPayment
      cannot :manage, Instalment
      cannot :manage, InstalmentPlan
      cannot :manage, ClientBankAccount
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
      can :crud, Offer
      can :crud, OfferItem
      can :crud, OfferRequest
      can :crud, OfferRequestItem
      can :crud, OfferRequestSupplier
      can :crud, OrderStatus
      can :crud, PaymentMethod
      can :crud, PurchasePrice
      can :crud, ProductCompanyPrice
      can :crud, PurchaseOrder
      can :crud, PurchaseOrderItem
      can :crud, PurchaseOrderItemBalance
      can :crud, Supplier
      can :crud, SupplierBankAccount
      can :crud, SupplierContact
      can :crud, SupplierInvoice
      can :crud, SupplierInvoiceApproval
      can :crud, SupplierInvoiceItem
      can :crud, SupplierPayment
      # Sepecial ag2Admin roles
      can :crud, Entity
    elsif user.has_role? :ag2Purchase_Guest
      can :read, Activity
      can :read, Offer
      can :read, OfferItem
      can :read, OfferRequest
      can :read, OfferRequestItem
      can :read, OfferRequestSupplier
      can :read, OrderStatus
      can :read, PaymentMethod
      can :read, PurchasePrice
      can :read, ProductCompanyPrice
      can :read, PurchaseOrder
      can :read, PurchaseOrderItem
      can :read, PurchaseOrderItemBalance
      can :read, Supplier
      can :read, SupplierBankAccount
      can :read, SupplierContact
      can :read, SupplierInvoice
      can :read, SupplierInvoiceApproval
      can :read, SupplierInvoiceItem
      can :read, SupplierPayment
    elsif user.has_role? :ag2Purchase_Banned
      cannot :manage, Activity
      cannot :manage, Offer
      cannot :manage, OfferItem
      cannot :manage, OfferRequest
      cannot :manage, OfferRequestItem
      cannot :manage, OfferRequestSupplier
      cannot :manage, OrderStatus
      cannot :manage, PaymentMethod
      cannot :manage, PurchasePrice
      cannot :manage, ProductCompanyPrice
      cannot :manage, PurchaseOrder
      cannot :manage, PurchaseOrderItem
      cannot :manage, PurchaseOrderItemBalance
      cannot :manage, Supplier
      cannot :manage, SupplierBankAccount
      cannot :manage, SupplierContact
      cannot :manage, SupplierInvoice
      cannot :manage, SupplierInvoiceApproval
      cannot :manage, SupplierInvoiceItem
      cannot :manage, SupplierPayment
    end
    # ag2Products (ag2Logistics)
    if user.has_role? :ag2Logistics_User
      can :crud, DeliveryNote
      can :crud, DeliveryNoteItem
      can :crud, Manufacturer
      can :crud, Measure
      can :crud, ProductFamily
      can :crud, ProductType
      can :crud, Product
      can :crud, PurchaseOrder
      can :crud, PurchaseOrderItem
      can :crud, PurchaseOrderItemBalance
      can :crud, PurchasePrice
      can :crud, ProductCompanyPrice
      can :crud, ReceiptNote
      can :crud, ReceiptNoteItem
      can :crud, Store
      can :crud, Stock
      #can :crud, InventoryCountType
      can :read, InventoryCountType
      can :crud, InventoryCount
      can :crud, InventoryCountItem
    elsif user.has_role? :ag2Logistics_Guest
      can :read, DeliveryNote
      can :read, DeliveryNoteItem
      can :read, Manufacturer
      can :read, Measure
      can :read, ProductFamily
      can :read, ProductType
      can :read, Product
      can :read, PurchaseOrder
      can :read, PurchaseOrderItem
      can :read, PurchaseOrderItemBalance
      can :read, PurchasePrice
      can :read, ProductCompanyPrice
      can :read, ReceiptNote
      can :read, ReceiptNoteItem
      can :read, Store
      can :read, InventoryCountType
      can :read, InventoryCount
      can :read, InventoryCountItem
    elsif user.has_role? :ag2Logistics_Banned
      cannot :manage, DeliveryNote
      cannot :manage, DeliveryNoteItem
      cannot :manage, Manufacturer
      cannot :manage, Measure
      cannot :manage, ProductFamily
      cannot :manage, ProductType
      cannot :manage, Product
      cannot :manage, PurchaseOrder
      cannot :manage, PurchaseOrderItem
      cannot :manage, PurchaseOrderItemBalance
      cannot :manage, PurchasePrice
      cannot :manage, ProductCompanyPrice
      cannot :manage, ReceiptNote
      cannot :manage, ReceiptNoteItem
      cannot :manage, Store
      cannot :manage, Stock
      cannot :manage, InventoryCountType
      cannot :manage, InventoryCount
      cannot :manage, InventoryCountItem
    end
    # ag2Tech
    if user.has_role? :ag2Tech_User
      can :crud, BudgetHeading
      can :crud, BudgetPeriod
      can :crud, Budget
      can :crud, BudgetItem
      can :crud, BudgetRatio
      can :crud, ChargeAccount
      can :crud, ChargeGroup
      can :crud, InfrastructureType
      can :crud, Infrastructure
      can :crud, Project
      can :crud, Ratio
      can :crud, RatioGroup
      can :crud, Tool
      can :crud, Vehicle
      can :crud, WorkOrderArea
      can :crud, WorkOrderLabor
      can :crud, WorkOrderStatus
      can :crud, WorkOrderType
      can :crud, WorkOrder
      can :crud, WorkOrderItem
      can :crud, WorkOrderWorker
      can :crud, WorkOrderSubcontractor
      can :crud, WorkOrderTool
      can :crud, WorkOrderVehicle
    elsif user.has_role? :ag2Tech_Guest
      can :read, BudgetHeading
      can :read, BudgetPeriod
      can :read, Budget
      can :read, BudgetItem
      can :read, BudgetRatio
      can :read, ChargeAccount
      can :read, ChargeGroup
      can :read, InfrastructureType
      can :read, Infrastructure
      can :read, Project
      can :read, Ratio
      can :read, RatioGroup
      can :read, Tool
      can :read, Vehicle
      can :read, WorkOrderArea
      can :read, WorkOrderLabor
      can :read, WorkOrderStatus
      can :read, WorkOrderType
      can :read, WorkOrder
      can :read, WorkOrderItem
      can :read, WorkOrderWorker
      can :read, WorkOrderSubcontractor
      can :read, WorkOrderTool
      can :read, WorkOrderVehicle
    elsif user.has_role? :ag2Tech_Banned
      cannot :manage, BudgetHeading
      cannot :manage, BudgetPeriod
      cannot :manage, Budget
      cannot :manage, BudgetItem
      cannot :manage, BudgetRatio
      cannot :manage, ChargeAccount
      cannot :manage, ChargeGroup
      cannot :manage, InfrastructureType
      cannot :manage, Infrastructure
      cannot :manage, Project
      cannot :manage, Ratio
      cannot :manage, RatioGroup
      cannot :manage, Tool
      cannot :manage, Vehicle
      cannot :manage, WorkOrderArea
      cannot :manage, WorkOrderLabor
      cannot :manage, WorkOrderStatus
      cannot :manage, WorkOrderType
      cannot :manage, WorkOrder
      cannot :manage, WorkOrderItem
      cannot :manage, WorkOrderWorker
      cannot :manage, WorkOrderSubcontractor
      cannot :manage, WorkOrderTool
      cannot :manage, WorkOrderVehicle
    end

    # ag2Admin
    if (user.has_role? :ag2Admin_User) || (user.has_role? :ag2Human_User)
      can :crud, Department
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
