class AddCompanyToSupplierInvoices < ActiveRecord::Migration
  def self.up
    add_column :supplier_invoices, :company_id, :integer

    SupplierInvoice.find_each do |p|
      p.update_column(:company_id, p.project.company_id)
    end
  end

  def self.down
    remove_column :supplier_invoices, :company_id
  end
end
