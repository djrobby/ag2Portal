class InventoryCount < ActiveRecord::Base
  include ModelsModule

  belongs_to :inventory_count_type
  belongs_to :store
  belongs_to :product_family
  belongs_to :organization
  belongs_to :approver, class_name: 'User'
  attr_accessible :count_date, :count_no, :remarks, :inventory_count_type_id,
                  :store_id, :product_family_id, :organization_id,
                  :approver_id, :approval_date, :quick
  attr_accessible :inventory_count_items_attributes

  has_many :inventory_count_items, dependent: :destroy
  has_many :products, through: :inventory_count_items

  # Nested attributes
  accepts_nested_attributes_for :inventory_count_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  validates_associated :inventory_count_items

  validates :count_date,            :presence => true
  validates :count_no,              :presence => true,
                                    :length => { :is => 14 },
                                    :format => { with: /\A\d+\Z/, message: :code_invalid },
                                    :uniqueness => { :scope => :organization_id }
  validates :store,                 :presence => true
  validates :inventory_count_type,  :presence => true
  validates :organization,          :presence => true

  after_create :notify_on_create
  after_update :notify_on_update

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    if !self.count_date.blank?
      full_name += " " + formatted_date(self.count_date)
    end
    if !self.store.blank?
      full_name += " " + self.store.name
    end
    full_name
  end

  def full_no
    # Count no (Store id & year & sequential number) => SSSS-YYYY-NNNNNN
    count_no.blank? ? "" : count_no[0..3] + '-' + count_no[4..7] + '-' + count_no[8..13]
  end

  #
  # Calculated fields
  #
  def quantity
    inventory_count_items.sum("quantity")
  end

  def total
    total = 0
    inventory_count_items.each do |i|
      if !i.amount.blank?
        total += i.amount
      end
    end
    total
  end

  #
  # Class (self) user defined methods
  #
  # Initials: Count approved initial counts
  # _store is neccessary, _product is optional
  def self.how_many_initials(_store, _product)
    if _product.blank?
      where("store_id = ? AND inventory_count_type_id = ? AND NOT approver_id IS NULL", _store, 1).count
    else
      joins(:inventory_count_items).where("store_id = ? AND inventory_count_type_id = ? AND product_id= ? AND NOT approver_id IS NULL", _store, 1, _product).count
    end
  end

  # Regularizations: _store is neccessary, _product is optional
  def self.how_many_regularizations(_store, _product)
    if _product.blank?
      where("store_id = ? AND inventory_count_type_id = ?", _store, 2).count
    else
      joins(:inventory_count_items).where("store_id = ? AND inventory_count_type_id = ? AND product_id= ?", _store, 2, _product).count
    end
  end

  #
  # Records navigator
  #
  def to_first
    InventoryCount.order("count_no desc").first
  end

  def to_prev
    InventoryCount.where("count_no > ?", count_no).order("count_no desc").last
  end

  def to_next
    InventoryCount.where("count_no < ?", count_no).order("count_no desc").first
  end

  def to_last
    InventoryCount.order("count_no desc").last
  end

  searchable do
    text :count_no
    string :count_no, :multiple => true    # Multiple search values accepted in one search (inverse_no_search)
    integer :inventory_count_type_id
    integer :store_id, :multiple => true
    integer :product_family_id
    date :count_date
    integer :organization_id
    string :sort_no do
      count_no
    end
  end

  private

  #
  # Notifiers
  #
  # After create
  def notify_on_create
    # Always notify on create
    Notifier.inventory_count_saved(self, 1).deliver
    if check_if_approval_is_required
      Notifier.inventory_count_saved_with_approval(self, 1).deliver
    end
  end

  # After update
  def notify_on_update
    # Always notify on update
    Notifier.inventory_count_saved(self, 3).deliver
    if check_if_approval_is_required
      Notifier.inventory_count_saved_with_approval(self, 3).deliver
    end
  end

  #
  # Helper methods for notifiers
  #
  # Need approval?
  def check_if_approval_is_required
    approver_id.blank?
  end
end
