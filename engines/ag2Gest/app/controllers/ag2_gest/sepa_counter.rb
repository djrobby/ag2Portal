module Ag2Gest
  class SepaCounter
    include ModelsModule
    include REXML

    # Constants
    METODO_PAGO ||= 'DD'
    INDICADOR_APUNTE_CUENTA ||= 'true'
    SIEMPRE_SEPA ||= 'SEPA'
    SECUENCIA_ADEUDO ||= 'RCUR'
    PAIS ||= 'ES'
    MONEDA ||= 'EUR'
    BIC ||= 'NOTPROVIDED'
    GASTOS ||= 'SLEV'

    # Attributes
    attr_accessor :fichero
    attr_accessor :OrgnlMsgId
    attr_accessor :OrgnlPmtInfId
    attr_accessor :fecha_hora_confeccion
    attr_accessor :numero_total_adeudos
    attr_accessor :importe_total
    attr_accessor :sufijo
    attr_accessor :nif
    attr_accessor :fecha_devolucion
    attr_accessor :lista_cobros
    attr_accessor :remesa

    def initialize(file_to_process)
      # Set TXT file
      self.fichero = file_to_process
      # Initialize attribute default values
      self.lista_cobros = []
    end

    #
    # *** Writes & returns TXT stream
    #
    def write_txt
      true
    end # write_txt

    #
    # *** Returns current XML stream
    #
    def read_txt
      # Open TXT file
      f = File.open(self.fichero, "r")
      # Loop thru open file lines
      f.each_line do |line|
        # *** Save in returns array ***
        self.lista_cobros.push(referencia_adeudo: referencia_adeudo,
                                     codigo_rechazo: codigo_rechazo,
                                     importe_adeudo: importe_adeudo,
                                     fecha_cobro: fecha_cobro,
                                     referencia_mandato:referencia_mandato,
                                     fecha_firma_mandato: fecha_firma_mandato,
                                     concepto: concepto,
                                     nombre_deudor: nombre_deudor,
                                     cuenta_deudor: cuenta_deudor,
                                     bill_id: id_bill,
                                     client_payment_id: id_client_payment,
                                     receipt_no: receipt_no,
                                     client_id: id_client)
      end
      self.remesa = receipt_no
    end # read_txt
  end
end
