class ProcessedFileType < ActiveRecord::Base
  # CONSTANTS
  BANK_ORDER = 1
  BANK_RETURN = 2
  BANK_COUNTER = 3
  LEDGER_APP_SUPPLIERS = 4
  LEDGER_APP_SUPPLIER_INVOICES = 5
  LEDGER_APP_SUPPLIER_INVOICE_EFFECTS = 6
  LEDGER_APP_CLIENTS = 7
  LEDGER_APP_CLIENT_INVOICES = 8
  LEDGER_APP_CLIENT_INVOICE_EFFECTS = 9

  attr_accessible :name

  has_many :processed_files

  has_paper_trail

  validates :name,  :presence => true

  before_destroy :check_for_dependent_records

  private

  def check_for_dependent_records
    # Check for processed files
    if processed_files.count > 0
      errors.add(:base, I18n.t('activerecord.models.processed_file_type.check_for_processed_files'))
      return false
    end
  end
end
