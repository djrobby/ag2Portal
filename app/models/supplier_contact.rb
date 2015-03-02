class SupplierContact < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :organization
  attr_accessible :cellular, :department, :email, :extension, :first_name, :fiscal_id, :last_name,
                  :phone, :position, :remarks, :supplier_id, :organization_id,
                  :created_by, :updated_by, :is_contact, :shared_contact_id

  has_paper_trail

  validates :first_name,    :presence => true
  validates :last_name,     :presence => true
  validates :supplier,      :presence => true
  validates :organization,  :presence => true

  before_validation :fields_to_uppercase
  after_create :should_create_shared_contact, if: :is_contact?
  after_update :should_update_shared_contact, if: :is_contact?

  def fields_to_uppercase
    if !self.fiscal_id.blank?
      self[:fiscal_id].upcase!
    end
  end

  def full_name
    full_name = ""
    if !self.last_name.blank?
      full_name += self.last_name
    end
    if !self.first_name.blank?
      full_name += ", " + self.first_name
    end
    full_name
  end

  searchable do
    text :first_name, :last_name, :fiscal_id, :cellular, :phone, :email, :position
    string :last_name
    string :first_name
    integer :supplier_id
    integer :organization_id
  end

  private

  #
  # Triggers to update linked models
  #
  # After create
  # Should create new Shared Contact (shared_contact_id not set)
  def should_create_shared_contact
    _supplier = Supplier.find(supplier)
    _entity = Entity.find(_supplier.entity)
    # Maybe contact exists previously
    _contact = SharedContact.find_by_name_organization_type(last_name, first_name, organization_id, 2) rescue nil
    if _contact.nil?
      # Let's create a new contact
      _contact = create_shared_contact(_entity, _supplier)
    else
      # Contact exists, updates it
      _contact = update_shared_contact(_contact, _entity, _supplier)
    end
    # Update contact id
    self.update_column(:shared_contact_id, _contact.id) if !_contact.id.nil?
    true
  end

  # After update
  # Should update existing Shared Contact (shared_contact_id is set)
  def should_update_shared_contact
    _supplier = Supplier.find(supplier)
    _entity = Entity.find(_supplier.entity)
    # Retrieve contact by its id
    _contact = SharedContact.find(shared_contact_id) rescue nil
    if _contact.nil?
      # Not found ??? Maybe is another contact... Let's check it out
      _contact = SharedContact.find_by_name_organization_type(last_name, first_name, organization_id, 2) rescue nil
      if _contact.nil?
        # No contact yet: Let's create a new one
        _contact = create_shared_contact(_entity, _supplier)
      else
        # Contact exists but with a different id
        _contact = update_shared_contact(_contact, _entity, _supplier)
      end
    else
      # Contact found, updates it
      _contact = update_shared_contact(_contact, _entity, _supplier)
    end
    # Update contact id
    self.update_column(:shared_contact_id, _contact.id) if !_contact.id.nil?
    true
  end

  #
  # Helper methods for triggers
  #
  # Creates new Shared Contact
  def create_shared_contact(_entity, _supplier)
    _contact = SharedContact.create(first_name: first_name, last_name: last_name, company: _entity.company,
                                    fiscal_id: fiscal_id, street_type_id: _supplier.street_type_id, street_name: _supplier.street_name,
                                    street_number: _supplier.street_number, building: _supplier.building, floor: _supplier.floor,
                                    floor_office: _supplier.floor_office, zipcode_id: _supplier.zipcode_id, town_id: _supplier.town_id,
                                    province_id: _supplier.province_id, country_id: _supplier.country_id, phone: phone,
                                    extension: extension, fax: _supplier.fax, cellular: cellular,
                                    email: email, shared_contact_type_id: 2, region_id: _supplier.region_id,
                                    organization_id: organization_id, created_by: created_by, updated_by: updated_by,
                                    position: position)
    return _contact
  end

  # Updates existing Shared Contact
  def update_shared_contact(_contact, _entity, _supplier)
    _contact.attributes = { first_name: first_name, last_name: last_name, company: _entity.company,
                            fiscal_id: fiscal_id, street_type_id: _supplier.street_type_id, street_name: _supplier.street_name,
                            street_number: _supplier.street_number, building: _supplier.building, floor: _supplier.floor,
                            floor_office: _supplier.floor_office, zipcode_id: _supplier.zipcode_id, town_id: _supplier.town_id,
                            province_id: _supplier.province_id, country_id: _supplier.country_id, phone: phone,
                            extension: extension, fax: _supplier.fax, cellular: cellular,
                            email: email, shared_contact_type_id: 2, region_id: _supplier.region_id,
                            organization_id: organization_id, created_by: created_by, updated_by: updated_by,
                            position: position }
    _contact.save
    return _contact 
  end
end
