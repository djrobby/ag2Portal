namespace :db do
  desc "Reset counter_caches"
  task :reset_counters => :environment do
    Offer.find_each { |p| Offer.reset_counters(p.id, :purchase_orders) }
    SaleOffer.find_each { |p| SaleOffer.reset_counters(p.id, :invoices) }
    DebtClaim.find_each { |p| DebtClaim.reset_counters(p.id, :debt_claim_items) }
    Client.find_each { |p| Client.reset_counters(p.id, :subscribers) }
  end

  desc "Reset totals (should stop server before!)"
  task :reset_totals => :environment do
    puts "Task started at " + Time.now.to_s + "."

    puts "\tOfferRequest"
    OfferRequest.find_each do |p|
      p.update_column(:totals, p.total)
    end
    puts "\tOffer"
    Offer.find_each do |p|
      p.update_column(:totals, p.total)
    end
    puts "\tReceiptNote"
    ReceiptNote.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:quantities, p.quantity)
      p.update_column(:taxables, p.taxable)
    end
    puts "\tDeliveryNote"
    DeliveryNote.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:total_costs, p.costs)
      p.update_column(:quantities, p.quantity)
    end
    puts "\tPurchaseOrder"
    PurchaseOrder.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:quantities, p.quantity)
      p.update_column(:balances, p.balance)
    end
    puts "\tSupplierInvoice"
    SupplierInvoice.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:taxables, p.taxable)
      p.update_column(:total_taxes, p.taxes)
    end
    puts "\tWorkOrder"
    WorkOrder.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:this_costs, p.this_total_costs)
      p.update_column(:with_suborder_costs, p.total_costs)
    end
    puts "\tInventoryCount"
    InventoryCount.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:quantities, p.quantity)
    end
    puts "\tPreInvoice"
    PreInvoice.find_each do |p|
      p.update_column(:totals, p.total)
    end
    puts "\tInvoice"
    Invoice.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:receivables, p.receivable)
      p.update_column(:total_taxes, p.taxes)
    end
    puts "\tDebtClaim"
    DebtClaim.find_each do |p|
      p.update_column(:subtotals, p.subtotal)
      p.update_column(:surcharges, p.surcharge)
    end

    puts "Task finished at " + Time.now.to_s + "."
  end

  desc "Reset invoice totals (should stop server before!)"
  task :reset_invoice_totals => :environment do
    puts "Task started at " + Time.now.to_s + "."

    puts "\tPreInvoice"
    PreInvoice.find_each do |p|
      p.update_column(:totals, p.total)
    end
    puts "\tInvoice"
    Invoice.find_each do |p|
      p.update_column(:totals, p.total)
      p.update_column(:receivables, p.receivable)
      p.update_column(:total_taxes, p.taxes)
    end

    puts "Task finished at " + Time.now.to_s + "."
  end

  desc "Create invoices taxes (should stop server before!)"
  task :create_invoice_taxes => :environment do
    puts "Task started at " + Time.now.to_s + "."

    Invoice.find_each do |p|
      InvoiceTax.where(invoice_id: p.id).delete_all
      p.tax_breakdown.each do |tb|
        InvoiceTax.create(invoice_id: p.id, tax_type_id: tb[5], description: tb[4],
                          tax: tb[0], taxable: tb[1], tax_amount: tb[2], items_qty: tb[3])
      end
    end

    puts "Task finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex searchable models"
  task :reindex_models => :environment do
    puts "Task started at " + Time.now.to_s + "."

    puts "\tBill"
    Bill.index(batch_size: 1000)
    puts "\tBillableItem"
    BillableItem.index(batch_size: 1000)
    puts "\tBudget"
    Budget.index(batch_size: 1000)
    puts "\tCashDeskClosing"
    CashDeskClosing.index(batch_size: 1000)
    puts "\tCashMovement"
    CashMovement.index(batch_size: 1000)
    puts "\tChargeAccount"
    ChargeAccount.index(batch_size: 1000)
    puts "\tClient"
    Client.index(batch_size: 1000)
    puts "\tClientPayment"
    ClientPayment.index(batch_size: 1000)
    puts "\tContractingRequest"
    ContractingRequest.index(batch_size: 1000)
    puts "\tCorpContact"
    CorpContact.index(batch_size: 1000)
    puts "\tDebtClaim"
    DebtClaim.index(batch_size: 1000)
    puts "\tDebtClaimItem"
    DebtClaimItem.index(batch_size: 1000)
    puts "\tDeliveryNote"
    DeliveryNote.index(batch_size: 1000)
    puts "\tEntity"
    Entity.index(batch_size: 1000)
    puts "\tFormality"
    Formality.index(batch_size: 1000)
    puts "\tInfrastructure"
    Infrastructure.index(batch_size: 1000)
    puts "\tInstalmentInvoice"
    InstalmentInvoice.index(batch_size: 1000)
    puts "\tInventoryCount"
    InventoryCount.index(batch_size: 1000)
    puts "\tInventoryTransfer"
    InventoryTransfer.index(batch_size: 1000)
    puts "\tInvoice"
    Invoice.index(batch_size: 1000)
    puts "\tMeter"
    Meter.index(batch_size: 1000)
    puts "\tOffer"
    Offer.index(batch_size: 1000)
    puts "\tOfferRequest"
    OfferRequest.index(batch_size: 1000)
    puts "\tOffice"
    Office.index(batch_size: 1000)
    puts "\tProduct"
    Product.index(batch_size: 1000)
    puts "\tProductCompanyPrice"
    ProductCompanyPrice.index(batch_size: 1000)
    puts "\tProductFamily"
    ProductFamily.index(batch_size: 1000)
    puts "\tProject"
    Project.index(batch_size: 1000)
    puts "\tPurchaseOrder"
    PurchaseOrder.index(batch_size: 1000)
    puts "\tPurchasePrice"
    PurchasePrice.index(batch_size: 1000)
    puts "\tReading"
    Reading.index(batch_size: 1000)
    puts "\tReceiptNote"
    ReceiptNote.index(batch_size: 1000)
    puts "\tSaleOffer"
    SaleOffer.index(batch_size: 1000)
    puts "\tServicePoint"
    ServicePoint.index(batch_size: 1000)
    puts "\tSharedContact"
    SharedContact.index(batch_size: 1000)
    puts "\tStock"
    Stock.index(batch_size: 1000)
    puts "\tStreetDirectory"
    StreetDirectory.index(batch_size: 1000)
    puts "\tSubscriber"
    Subscriber.index(batch_size: 1000)
    puts "\tSupplier"
    Supplier.index(batch_size: 1000)
    puts "\tSupplierContact"
    SupplierContact.index(batch_size: 1000)
    puts "\tSupplierInvoice"
    SupplierInvoice.index(batch_size: 1000)
    puts "\tSupplierPayment"
    SupplierPayment.index(batch_size: 1000)
    puts "\tTariff"
    Tariff.index(batch_size: 1000)
    puts "\tTariffScheme"
    TariffScheme.index(batch_size: 1000)
    puts "\tTicket"
    Ticket.index(batch_size: 1000)
    puts "\tTimeRecord"
    TimeRecord.index(batch_size: 1000)
    puts "\tTool"
    Tool.index(batch_size: 1000)
    puts "\tVehicle"
    Vehicle.index(batch_size: 1000)
    puts "\tWaterConnectionContract"
    WaterConnectionContract.index(batch_size: 1000)
    puts "\tWaterSupplyContract"
    WaterSupplyContract.index(batch_size: 1000)
    puts "\tWorkOrder"
    WorkOrder.index(batch_size: 1000)
    puts "\tWorker"
    Worker.index(batch_size: 1000)
    puts "\tWorkerItem"
    WorkerItem.index(batch_size: 1000)
    puts "\tZipcode"
    Zipcode.index(batch_size: 1000)

    puts "Committing all..."
    Sunspot.commit
    puts "Task finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Bill model"
  task :reindex_bill => :environment do
    puts "Bill started at " + Time.now.to_s + "."
    Bill.index(batch_size: 1000)
    Sunspot.commit
    puts "Bill finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex BillableItem model"
  task :reindex_billable_item => :environment do
    puts "BillableItem started at " + Time.now.to_s + "."
    BillableItem.index(batch_size: 1000)
    Sunspot.commit
    puts "BillableItem finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Budget model"
  task :reindex_budget => :environment do
    puts "Budget started at " + Time.now.to_s + "."
    Budget.index(batch_size: 1000)
    Sunspot.commit
    puts "Budget finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex CashDeskClosing model"
  task :reindex_cash_desk_closing => :environment do
    puts "CashDeskClosing started at " + Time.now.to_s + "."
    CashDeskClosing.index(batch_size: 1000)
    Sunspot.commit
    puts "CashDeskClosing finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex CashMovement model"
  task :reindex_cash_movement => :environment do
    puts "CashMovement started at " + Time.now.to_s + "."
    CashMovement.index(batch_size: 1000)
    Sunspot.commit
    puts "CashMovement finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ChargeAccount model"
  task :reindex_charge_account => :environment do
    puts "ChargeAccount started at " + Time.now.to_s + "."
    ChargeAccount.index(batch_size: 1000)
    Sunspot.commit
    puts "ChargeAccount finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Client model"
  task :reindex_client => :environment do
    puts "Client started at " + Time.now.to_s + "."
    Client.index(batch_size: 1000)
    Sunspot.commit
    puts "Client finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ClientPayment model"
  task :reindex_client_payment => :environment do
    puts "ClientPayment started at " + Time.now.to_s + "."
    ClientPayment.index(batch_size: 1000)
    Sunspot.commit
    puts "ClientPayment finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ContractingRequest model"
  task :reindex_contracting_request => :environment do
    puts "ContractingRequest started at " + Time.now.to_s + "."
    ContractingRequest.index(batch_size: 1000)
    Sunspot.commit
    puts "ContractingRequest finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex CorpContact model"
  task :reindex_corp_contact => :environment do
    puts "CorpContact started at " + Time.now.to_s + "."
    CorpContact.index(batch_size: 1000)
    Sunspot.commit
    puts "CorpContact finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex DebtClaim model"
  task :reindex_debt_claim => :environment do
    puts "DebtClaim started at " + Time.now.to_s + "."
    DebtClaim.index(batch_size: 1000)
    Sunspot.commit
    puts "DebtClaim finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex DebtClaimItem model"
  task :reindex_debt_claim_item => :environment do
    puts "DebtClaimItem started at " + Time.now.to_s + "."
    DebtClaimItem.index(batch_size: 1000)
    Sunspot.commit
    puts "DebtClaimItem finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex DeliveryNote model"
  task :reindex_delivery_note => :environment do
    puts "DeliveryNote started at " + Time.now.to_s + "."
    DeliveryNote.index(batch_size: 1000)
    Sunspot.commit
    puts "DeliveryNote finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Entity model"
  task :reindex_entity => :environment do
    puts "Entity started at " + Time.now.to_s + "."
    Entity.index(batch_size: 1000)
    Sunspot.commit
    puts "Entity finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Formality model"
  task :reindex_formality => :environment do
    puts "Formality started at " + Time.now.to_s + "."
    Formality.index(batch_size: 1000)
    Sunspot.commit
    puts "Formality finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Infrastructure model"
  task :reindex_infrastructure => :environment do
    puts "Infrastructure started at " + Time.now.to_s + "."
    Infrastructure.index(batch_size: 1000)
    Sunspot.commit
    puts "Infrastructure finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex InstalmentInvoice model"
  task :reindex_instalment_invoice => :environment do
    puts "InstalmentInvoice started at " + Time.now.to_s + "."
    InstalmentInvoice.index(batch_size: 1000)
    Sunspot.commit
    puts "InstalmentInvoice finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex InventoryCount model"
  task :reindex_inventory_count => :environment do
    puts "InventoryCount started at " + Time.now.to_s + "."
    InventoryCount.index(batch_size: 1000)
    Sunspot.commit
    puts "InventoryCount finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex InventoryTransfer model"
  task :reindex_inventory_transfer => :environment do
    puts "InventoryTransfer started at " + Time.now.to_s + "."
    InventoryTransfer.index(batch_size: 1000)
    Sunspot.commit
    puts "InventoryTransfer finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Invoice model"
  task :reindex_invoice => :environment do
    puts "Invoice started at " + Time.now.to_s + "."
    Invoice.index(batch_size: 1000)
    Sunspot.commit
    puts "Invoice finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Meter model"
  task :reindex_meter => :environment do
    puts "Meter started at " + Time.now.to_s + "."
    Meter.index(batch_size: 1000)
    Sunspot.commit
    puts "Meter finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Offer model"
  task :reindex_offer => :environment do
    puts "Offer started at " + Time.now.to_s + "."
    Offer.index(batch_size: 1000)
    Sunspot.commit
    puts "Offer finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex OfferRequest model"
  task :reindex_offer_request => :environment do
    puts "OfferRequest started at " + Time.now.to_s + "."
    OfferRequest.index(batch_size: 1000)
    Sunspot.commit
    puts "OfferRequest finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Office model"
  task :reindex_office => :environment do
    puts "Office started at " + Time.now.to_s + "."
    Office.index(batch_size: 1000)
    Sunspot.commit
    puts "Office finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Product model"
  task :reindex_product => :environment do
    puts "Product started at " + Time.now.to_s + "."
    Product.index(batch_size: 1000)
    Sunspot.commit
    puts "Product finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ProductCompanyPrice model"
  task :reindex_product_company_price => :environment do
    puts "ProductCompanyPrice started at " + Time.now.to_s + "."
    ProductCompanyPrice.index(batch_size: 1000)
    Sunspot.commit
    puts "ProductCompanyPrice finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ProductFamily model"
  task :reindex_product_family => :environment do
    puts "ProductFamily started at " + Time.now.to_s + "."
    ProductFamily.index(batch_size: 1000)
    Sunspot.commit
    puts "ProductFamily finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Project model"
  task :reindex_project => :environment do
    puts "Project started at " + Time.now.to_s + "."
    Project.index(batch_size: 1000)
    Sunspot.commit
    puts "Project finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex PurchaseOrder model"
  task :reindex_purchase_order => :environment do
    puts "PurchaseOrder started at " + Time.now.to_s + "."
    PurchaseOrder.index(batch_size: 1000)
    Sunspot.commit
    puts "PurchaseOrder finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex PurchasePrice model"
  task :reindex_purchase_price => :environment do
    puts "PurchasePrice started at " + Time.now.to_s + "."
    PurchasePrice.index(batch_size: 1000)
    Sunspot.commit
    puts "PurchasePrice finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Reading model"
  task :reindex_reading => :environment do
    puts "Reading started at " + Time.now.to_s + "."
    Reading.index(batch_size: 1000)
    Sunspot.commit
    puts "Reading finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ReceiptNote model"
  task :reindex_receipt_note => :environment do
    puts "ReceiptNote started at " + Time.now.to_s + "."
    ReceiptNote.index(batch_size: 1000)
    Sunspot.commit
    puts "ReceiptNote finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex SaleOffer model"
  task :reindex_sale_offer => :environment do
    puts "SaleOffer started at " + Time.now.to_s + "."
    SaleOffer.index(batch_size: 1000)
    Sunspot.commit
    puts "SaleOffer finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex ServicePoint model"
  task :reindex_service_point => :environment do
    puts "ServicePoint started at " + Time.now.to_s + "."
    ServicePoint.index(batch_size: 1000)
    Sunspot.commit
    puts "ServicePoint finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex SharedContact model"
  task :reindex_shared_contact => :environment do
    puts "SharedContact started at " + Time.now.to_s + "."
    SharedContact.index(batch_size: 1000)
    Sunspot.commit
    puts "SharedContact finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Stock model"
  task :reindex_stock => :environment do
    puts "Stock started at " + Time.now.to_s + "."
    Stock.index(batch_size: 1000)
    Sunspot.commit
    puts "Stock finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex StreetDirectory model"
  task :reindex_street_directory => :environment do
    puts "StreetDirectory started at " + Time.now.to_s + "."
    StreetDirectory.index(batch_size: 1000)
    Sunspot.commit
    puts "StreetDirectory finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Subscriber model"
  task :reindex_subscriber => :environment do
    puts "Subscriber started at " + Time.now.to_s + "."
    Subscriber.index(batch_size: 1000)
    Sunspot.commit
    puts "Subscriber finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Supplier model"
  task :reindex_supplier => :environment do
    puts "Supplier started at " + Time.now.to_s + "."
    Supplier.index(batch_size: 1000)
    Sunspot.commit
    puts "Supplier finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex SupplierContact model"
  task :reindex_supplier_contact => :environment do
    puts "SupplierContact started at " + Time.now.to_s + "."
    SupplierContact.index(batch_size: 1000)
    Sunspot.commit
    puts "SupplierContact finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex SupplierInvoice model"
  task :reindex_supplier_invoice => :environment do
    puts "SupplierInvoice started at " + Time.now.to_s + "."
    SupplierInvoice.index(batch_size: 1000)
    Sunspot.commit
    puts "SupplierInvoice finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex SupplierPayment model"
  task :reindex_supplier_payment => :environment do
    puts "SupplierPayment started at " + Time.now.to_s + "."
    SupplierPayment.index(batch_size: 1000)
    Sunspot.commit
    puts "SupplierPayment finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Tariff model"
  task :reindex_tariff => :environment do
    puts "Tariff started at " + Time.now.to_s + "."
    Tariff.index(batch_size: 1000)
    Sunspot.commit
    puts "Tariff finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex TariffScheme model"
  task :reindex_tariff_scheme => :environment do
    puts "TariffScheme started at " + Time.now.to_s + "."
    TariffScheme.index(batch_size: 1000)
    Sunspot.commit
    puts "TariffScheme finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Ticket model"
  task :reindex_ticket => :environment do
    puts "Ticket started at " + Time.now.to_s + "."
    Ticket.index(batch_size: 1000)
    Sunspot.commit
    puts "Ticket finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex TimeRecord model"
  task :reindex_time_record => :environment do
    puts "TimeRecord started at " + Time.now.to_s + "."
    TimeRecord.index(batch_size: 1000)
    Sunspot.commit
    puts "TimeRecord finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Tool model"
  task :reindex_tool => :environment do
    puts "Tool started at " + Time.now.to_s + "."
    Tool.index(batch_size: 1000)
    Sunspot.commit
    puts "Tool finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Vehicle model"
  task :reindex_vehicle => :environment do
    puts "Vehicle started at " + Time.now.to_s + "."
    Vehicle.index(batch_size: 1000)
    Sunspot.commit
    puts "Vehicle finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex WaterConnectionContract model"
  task :reindex_water_connection_contract => :environment do
    puts "WaterConnectionContract started at " + Time.now.to_s + "."
    WaterConnectionContract.index(batch_size: 1000)
    Sunspot.commit
    puts "WaterConnectionContract finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex WaterSupplyContract model"
  task :reindex_water_supply_contract => :environment do
    puts "WaterSupplyContract started at " + Time.now.to_s + "."
    WaterSupplyContract.index(batch_size: 1000)
    Sunspot.commit
    puts "WaterSupplyContract finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex WorkOrder model"
  task :reindex_work_order => :environment do
    puts "WorkOrder started at " + Time.now.to_s + "."
    WorkOrder.index(batch_size: 1000)
    Sunspot.commit
    puts "WorkOrder finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Worker model"
  task :reindex_worker => :environment do
    puts "Worker started at " + Time.now.to_s + "."
    Worker.index(batch_size: 1000)
    Sunspot.commit
    puts "Worker finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex WorkerItem model"
  task :reindex_worker_item => :environment do
    puts "WorkerItem started at " + Time.now.to_s + "."
    WorkerItem.index(batch_size: 1000)
    Sunspot.commit
    puts "WorkerItem finished at " + Time.now.to_s + "."
  end

  desc "Solr reindex Zipcode model"
  task :reindex_zipcode => :environment do
    puts "Zipcode started at " + Time.now.to_s + "."
    Zipcode.index(batch_size: 1000)
    Sunspot.commit
    puts "Zipcode finished at " + Time.now.to_s + "."
  end
end
