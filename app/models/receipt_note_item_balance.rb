class ReceiptNoteItemBalance < ActiveRecord::Base
  belongs_to :receipt_note_item
  attr_accessible :receipt_note_item_id, :receipt_note_item_quantity, :invoiced_quantity, :balance
end
