class InventoryTransfer < ActiveRecord::Base
  include ModelsModule

  belongs_to :organization
  belongs_to :company
  belongs_to :outbound_store, class_name: 'Store'
  belongs_to :inbound_store, class_name: 'Store'
  belongs_to :approver, class_name: 'User'

  attr_accessible :approval_date, :transfer_date, :transfer_no,
                  :organization_id, :outbound_store_id, :inbound_store_id, :approver_id
  attr_accessible :inventory_transfer_items_attributes

  has_many :inventory_transfer_items, dependent: :destroy
  has_many :products, through: :inventory_transfer_items

  # Nested attributes
  accepts_nested_attributes_for :inventory_transfer_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :inventory_transfer_items

  validates :transfer_date,   :presence => true
  validates :transfer_no,     :presence => true,
                              :length => { :is => 14 },
                              :format => { with: /\A\d+\Z/, message: :code_invalid },
                              :uniqueness => { :scope => :organization_id }
  validates :outbound_store,  :presence => true
  validates :inbound_store,   :presence => true
  validates :organization,    :presence => true
  validates :company,         :presence => true

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.transfer_date.blank?
      full_name += " " + formatted_date(self.transfer_date)
    end
    if !self.outbound_store.blank?
      full_name += " " + self.outbound_store.name
      if !self.inbound_store.blank?
        full_name += "->" + self.inbound_store.name
      end
    end
    full_name
  end

  def full_no
    # Transfer no (Company id & year & sequential number) => CCCC-YYYY-NNNNNN
    transfer_no.blank? ? "" : transfer_no[0..3] + '-' + transfer_no[4..7] + '-' + transfer_no[8..13]
  end

  #
  # Calculated fields
  #
  def quantity
    inventory_transfer_items.sum("quantity")
  end

  def total
    total = 0
    inventory_transfer_items.each do |i|
      if !i.amount.blank?
        total += i.amount
      end
    end
    total
  end

  #
  # Records navigator
  #
  def to_first
    InventoryTransfer.order("transfer_no desc").first
  end

  def to_prev
    InventoryTransfer.where("transfer_no > ?", transfer_no).order("transfer_no desc").last
  end

  def to_next
    InventoryTransfer.where("transfer_no < ?", transfer_no).order("transfer_no desc").first
  end

  def to_last
    InventoryTransfer.order("transfer_no desc").last
  end

  searchable do
    text :transfer_no
    string :transfer_no, :multiple => true    # Multiple search values accepted in one search (inverse_no_search)
    integer :organization_id
    integer :company_id
    integer :outbound_store_id, :multiple => true
    integer :inbound_store_id, :multiple => true
    date :transfer_date
    string :sort_no do
      transfer_no
    end
  end
end
