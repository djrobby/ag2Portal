class Supplier < ActiveRecord::Base
  attr_accessible :fiscal_id, :name, :supplier_code

  has_paper_trail

  validates :name,                :presence => true
  validates :supplier_code,       :presence => true,
                                  :length => { :minimum => 5 },
                                  :uniqueness => true
  validates :fiscal_id,           :presence => true,
                                  :length => { :minimum => 9 },
                                  :uniqueness => true

  before_validation :fields_to_uppercase
  def fields_to_uppercase
    self[:fiscal_id].upcase!
    self[:supplier_code].upcase!
  end

  def to_label
    "#{name} (#{supplier_code})"
  end

  #
  # Records navigator
  #
  def to_first
    Supplier.order("supplier_code").first
  end

  def to_prev
    Supplier.where("supplier_code < ?", supplier_code).order("supplier_code").last
  end

  def to_next
    Supplier.where("supplier_code > ?", supplier_code).order("supplier_code").first
  end

  def to_last
    Supplier.order("supplier_code").last
  end

  searchable do
    text :supplier_code, :name, :fiscal_id
    string :supplier_code
  end
end
