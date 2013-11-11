class Stock < ActiveRecord::Base
  belongs_to :product
  belongs_to :store
  attr_accessible :current, :initial, :location, :minimum, :product_id, :store_id

  has_paper_trail

  validates :product_id,  :presence => true
  validates :store_id,    :presence => true

  searchable do
    integer :product_id
    integer :store_id
    integer :id
    decimal :initial
    decimal :current
    decimal :minimum
  end
end
