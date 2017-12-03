class CashMovementType < ActiveRecord::Base
  # CONSTANTS
  INFLOW = "1"
  OUTFLOW = "2"

  belongs_to :organization
  attr_accessible :code, :name, :type_id, :organization_id

  has_many :cash_desk_closing_items

  validates :organization,  :presence => true
  validates :code,          :presence => true,
                            :length => { :is => 3 },
                            :format => { with: /\A\d+\Z/, message: :code_invalid },
                            :uniqueness => { :scope => [:organization_id, :type_id] }
  validates :type_id,       :presence => true,
                            :length => { :is => 1 },
                            :format => { with: /\A\d+\Z/, message: :type_invalid }

  def type_label
    case type_id
      when "1" then I18n.t('activerecord.attributes.cash_movement_type.type_i')
      when "2" then I18n.t('activerecord.attributes.cash_movement_type.type_o')
      else 'N/A'
    end
  end
end
