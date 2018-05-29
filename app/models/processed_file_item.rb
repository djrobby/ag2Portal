class ProcessedFileItem < ActiveRecord::Base
  belongs_to :processed_file
  attr_accessible :processed_file_id,
                  :item_amount, :item_id, :item_remarks, :item_type, :subitem_id,
                  :item_model, :subitem_model, :processed_model, :processed_id, :multiple_processed_id

  def item_label
    case item_model
      when 'Bill' then I18n.t('activerecord.models.bill.one')
      else 'N/A'
    end
  end

  def item_no
    case item_model
      when 'Bill' then Bill.find(item_id).invoice_based_old_no_real_no
      else 'N/A'
    end
  end

  def subitem_label
    case subitem_model
      when 'Invoice' then I18n.t('activerecord.models.invoice.one')
      else 'N/A'
    end
  end

  def subitem_no
    case subitem_model
      when 'Invoice' then Invoice.find(subitem_id).old_no_based_real_no
      else 'N/A'
    end
  end

  def processed_label
    case processed_model
      when 'ClientPayment' then I18n.t('activerecord.models.client_payment.one')
      else 'N/A'
    end
  end

  def processed_no
    case processed_model
      when 'ClientPayment' then ClientPayment.find(processed_id).full_no
      else 'N/A'
    end
  end
end
