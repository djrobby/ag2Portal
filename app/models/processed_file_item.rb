class ProcessedFileItem < ActiveRecord::Base
  belongs_to :processed_file
  attr_accessible :item_amount, :item_id, :item_remarks, :item_type, :subitem_id,
                  :item_model, :subitem_model
end
