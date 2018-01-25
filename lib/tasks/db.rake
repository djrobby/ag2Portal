namespace :db do
  desc "Reset counter_caches"
  task :reset_counters => :environment do
    Offer.find_each { |p| Offer.reset_counters(p.id, :purchase_orders) }
    SaleOffer.find_each { |p| SaleOffer.reset_counters(p.id, :invoices) }
    DebtClaim.find_each { |p| DebtClaim.reset_counters(p.id, :debt_claim_items) }
    Client.find_each { |p| Client.reset_counters(p.id, :subscribers) }
  end

  desc "Puts"
  task :puts => :environment do
    puts "Hello"
  end

  desc "Solr reindex searchable models"
  task :reindex_models => :environment do
    puts "Bill"
    Bill.index(batch_size: 1000)
    puts "BillableItem"
    BillableItem.index(batch_size: 1000)
    puts "Budget"
    Budget.index(batch_size: 1000)
    puts "CashDeskClosing"
    CashDeskClosing.index(batch_size: 1000)
    puts "CashMovement"
    CashMovement.index(batch_size: 1000)
    puts "ChargeAccount"
    ChargeAccount.index(batch_size: 1000)
    puts "Client"
    Client.index(batch_size: 1000)
    puts "ClientPayment"
    ClientPayment.index(batch_size: 1000)
    puts "ContractingRequest"
    ContractingRequest.index(batch_size: 1000)
    puts "CorpContact"
    CorpContact.index(batch_size: 1000)
    puts "DebtClaim"
    DebtClaim.index(batch_size: 1000)
    puts "DebtClaimItem"
    DebtClaimItem.index(batch_size: 1000)
    puts "DeliveryNote"
    DeliveryNote.index(batch_size: 1000)
    puts "Entity"
    Entity.index(batch_size: 1000)
    puts "Formality"
    Formality.index(batch_size: 1000)
    puts "Infrastructure"
    Infrastructure.index(batch_size: 1000)
    puts "InstalmentInvoice"
    InstalmentInvoice.index(batch_size: 1000)
    puts "InventoryCount"
    InventoryCount.index(batch_size: 1000)
    puts "InventoryTransfer"
    InventoryTransfer.index(batch_size: 1000)
    puts "Invoice"
    Invoice.index(batch_size: 1000)
    puts "Meter"
    Meter.index(batch_size: 1000)
    puts "Offer"
    Offer.index(batch_size: 1000)
    puts "OfferRequest"
    OfferRequest.index(batch_size: 1000)
    puts "Office"
    Office.index(batch_size: 1000)
    puts "Product"
    Product.index(batch_size: 1000)
    puts "ProductCompanyPrice"
    ProductCompanyPrice.index(batch_size: 1000)
    puts "ProductFamily"
    ProductFamily.index(batch_size: 1000)
    puts "Project"
    Project.index(batch_size: 1000)
    puts "PurchaseOrder"
    PurchaseOrder.index(batch_size: 1000)
    puts "PurchasePrice"
    PurchasePrice.index(batch_size: 1000)
    puts "Reading"
    Reading.index(batch_size: 1000)
    puts "ReceiptNote"
    ReceiptNote.index(batch_size: 1000)
    puts "SaleOffer"
    SaleOffer.index(batch_size: 1000)
    puts "ServicePoint"
    ServicePoint.index(batch_size: 1000)
    puts "SharedContact"
    SharedContact.index(batch_size: 1000)
    puts "Stock"
    Stock.index(batch_size: 1000)
    puts "StreetDirectory"
    StreetDirectory.index(batch_size: 1000)
    puts "Subscriber"
    Subscriber.index(batch_size: 1000)
    puts "Supplier"
    Supplier.index(batch_size: 1000)
    puts "SupplierContact"
    SupplierContact.index(batch_size: 1000)
    puts "SupplierInvoice"
    SupplierInvoice.index(batch_size: 1000)
    puts "SupplierPayment"
    SupplierPayment.index(batch_size: 1000)
    puts "Tariff"
    Tariff.index(batch_size: 1000)
    puts "TariffScheme"
    TariffScheme.index(batch_size: 1000)
    puts "Ticket"
    Ticket.index(batch_size: 1000)
    puts "TimeRecord"
    TimeRecord.index(batch_size: 1000)
    puts "Tool"
    Tool.index(batch_size: 1000)
    puts "Vehicle"
    Vehicle.index(batch_size: 1000)
    puts "WaterConnectionContract"
    WaterConnectionContract.index(batch_size: 1000)
    puts "WaterSupplyContract"
    WaterSupplyContract.index(batch_size: 1000)
    puts "WorkOrder"
    WorkOrder.index(batch_size: 1000)
    puts "Worker"
    Worker.index(batch_size: 1000)
    puts "WorkerItem"
    WorkerItem.index(batch_size: 1000)
    puts "Zipcode"
    Zipcode.index(batch_size: 1000)

    puts "Committing all..."
    Sunspot.commit
    puts "Finished."
  end
end
