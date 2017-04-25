class LoadPaymentTypes < ActiveRecord::Migration
  def self.up
    types = ['CASH','BANK','FRACTIONATED','COUNTER','OTHERS']
    for type in types
      PaymentType.create(name: type, organization_id: 1)
    end
  end

  def self.down
    PaymentType.delete_all
  end
end
