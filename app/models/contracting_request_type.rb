class ContractingRequestType < ActiveRecord::Base
  # CONSTANTS
  SUPPLY = 1
  SUBROGATION = 2
  CONNECTION = 3
  CHANGE_OWNERSHIP = 4
  CHANGE_USE_AND_TARIFF = 5 #Cambio de uso y se cambiaran tarifas // Cambio de tarifa por cambio de calibre del contador y no tiene por que cambiar el uso.
  CANCELLATION = 6 #Baja de servicio.
  ADD_CONCEPT = 7 #Añadir conceptos contratable a un abonado.

  attr_accessible :description

  has_many :contracting_requests

  has_paper_trail

  validates :description,  :presence => true

  #before_validation :fields_to_uppercase

  def fields_to_uppercase
    if !self.description.blank?
      self[:description].upcase!
    end
  end
end
