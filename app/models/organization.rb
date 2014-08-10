class Organization < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_organizations
  attr_accessible :name, :hd_email

  # admin
  has_many :companies
  has_many :entities
  # directory
  has_many :corp_contacts
  has_many :shared_contacts
  # finance
  # gest
  has_many :clients
  # helpdesk
  has_many :technicians
  has_many :tickets
  # human
  has_many :workers
  has_many :collective_agreements
  has_many :contract_types
  has_many :degree_types
  has_many :departments
  has_many :insurances
  has_many :professional_groups
  has_many :salary_concepts
  # logistics
  has_many :products
  has_many :product_families
  has_many :stores
  has_many :delivery_notes
  has_many :receipt_notes
  # purchase
  has_many :suppliers
  has_many :payment_methods
  has_many :offer_requests
  has_many :offers
  has_many :purchase_orders
  has_many :supplier_invoices
  has_many :supplier_payments
  # tech
  has_many :projects
  has_many :work_orders
  has_many :charge_accounts
  has_many :work_order_labors
  has_many :work_order_types

  has_paper_trail

  validates :name,  :presence => true

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.name.blank?
      self[:name].upcase!
    end
  end

  private

  def check_for_dependent_records
    # Check for companies
    if companies.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_companies'))
      return false
    end
    # Check for entities
    if entities.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_entities'))
      return false
    end
    # Check for clients
    if clients.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_clients'))
      return false
    end
    # Check for suppliers
    if suppliers.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_suppliers'))
      return false
    end
    # Check for workers
    if workers.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_workers'))
      return false
    end
    # Check for technicians
    if technicians.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_technicians'))
      return false
    end
    # Check for corporate contacts
    if corp_contacts.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_corp_contacts'))
      return false
    end
    # Check for products
    if products.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_products'))
      return false
    end
    # Check for stores
    if stores.count > 0
      errors.add(:base, I18n.t('activerecord.models.organization.check_for_stores'))
      return false
    end
  end
end
