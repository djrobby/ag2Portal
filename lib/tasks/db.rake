namespace :db do
  desc "Reset counter_caches"
  task :reset_counters => :environment do
    Offer.find_each { |p| Offer.reset_counters(p.id, :purchase_orders) }
    SaleOffer.find_each { |p| SaleOffer.reset_counters(p.id, :invoices) }
    DebtClaim.find_each { |p| DebtClaim.reset_counters(p.id, :debt_claim_items) }
    Client.find_each { |p| Client.reset_counters(p.id, :subscribers) }
  end
end
