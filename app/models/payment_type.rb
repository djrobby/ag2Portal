class PaymentType < ActiveRecord::Base
  belongs_to :payment_method # Payment method for charges
  belongs_to :organization
  belongs_to :return_payment_method, :class_name => 'PaymentMethod' # Payment method for returns
  attr_accessible :name, :payment_method_id, :organization_id, :return_payment_method_id

  #
  # Class (self) user defined methods
  #
  def self.code_with_param(p)
    case p
    when 1 then I18n.t('activerecord.attributes.client_payment.payment_type_code_1')
    when 2 then I18n.t('activerecord.attributes.client_payment.payment_type_code_2')
    when 3 then I18n.t('activerecord.attributes.client_payment.payment_type_code_3')
    when 4 then I18n.t('activerecord.attributes.client_payment.payment_type_code_4')
    when 5 then I18n.t('activerecord.attributes.client_payment.payment_type_code_5')
    end
  end

end
