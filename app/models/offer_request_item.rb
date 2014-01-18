class OfferRequestItem < ActiveRecord::Base
  belongs_to :offer_request
  belongs_to :product
  belongs_to :tax_type
  belongs_to :project
  belongs_to :store
  belongs_to :work_order
  belongs_to :charge_account
  attr_accessible :description, :price, :quantity,
                  :offer_request_id, :product_id, :tax_type_id,
                  :project_id, :store_id, :work_order_id, :charge_account_id

  has_paper_trail

  validates :description,     :presence => true
  validates :offer_request,   :presence => true
  validates :product,         :presence => true
  validates :tax_type,        :presence => true
  validates :project,         :presence => true
  validates :store,           :presence => true
  validates :work_order,      :presence => true
  validates :charge_account,  :presence => true
end
