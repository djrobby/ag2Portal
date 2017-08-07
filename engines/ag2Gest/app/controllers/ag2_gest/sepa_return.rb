module Ag2Gest
  class SepaReturn
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
    attr_accessor :sufijo
    attr_accessor :nif
    attr_accessor :fecha_cobro
    attr_accessor :lista_devoluciones

    def initialize(file_to_process)
      # Open XML file
      self.fichero = File.new(file_to_process)
      # Initialize XML Document
      @doc = Document.new self.fichero
      # Initialize attribute default values
      self.lista_devoluciones = []
    end

    #
    # *** Writes & returns XML stream
    #
    def write_xml
      true
    end # write_xml

    #
    # *** Returns current XML stream
    #
    def read_xml
      # date & time of rejections
      self.fecha_hora_confeccion = @doc.get_elements('//CreDtTm')[0].text
      # fiscal id, bank suffix & date of order
      self.OrgnlMsgId = @doc.get_elements('//OrgnlMsgId')[0].text
      self.OrgnlPmtInfId = @doc.get_elements('//OrgnlPmtInfId')[0].text
      begin   # based on OrgnlPmtInfId
        self.sufijo = self.OrgnlPmtInfId[4,3]
        self.nif = self.OrgnlPmtInfId[7,9]
        self.fecha_cobro = self.OrgnlPmtInfId[16,8]
      rescue  # based on OrgnlMsgId
        self.sufijo = self.OrgnlMsgId[22,3]
        self.nif = self.OrgnlMsgId[25,9]
        self.fecha_cobro = self.OrgnlMsgId[3,8]
      end
      #
      # Loop thru rejections (TxInfAndSts)
      #
      @doc.elements.each('//TxInfAndSts') do |e|
        referencia_adeudo = e.elements['OrgnlEndToEndId'].text
        codigo_rechazo = e.elements['StsRsnInf'].elements['Rsn'].elements['Cd'].text
        importe_adeudo = e.elements['OrgnlTxRef'].elements['Amt'].elements['InstdAmt'].text.to_d
        fecha_cobro = e.elements['OrgnlTxRef'].elements['ReqdColltnDt'].text.to_date
        referencia_mandato = e.elements['OrgnlTxRef'].elements['MndtRltdInf'].elements['MndtId'].text
        fecha_firma_mandato = e.elements['OrgnlTxRef'].elements['MndtRltdInf'].elements['DtOfSgntr'].text.to_date
        concepto = e.elements['OrgnlTxRef'].elements['RmtInf'].elements['Ustrd'].text
        nombre_deudor = e.elements['OrgnlTxRef'].elements['Dbtr'].elements['Nm'].text
        cuenta_deudor = e.elements['OrgnlTxRef'].elements['DbtrAcct'].elements['Id'].elements['IBAN'].text
        id_bill = referencia_adeudo.first(16)
        codigo_cliente = referencia_mandato.last(8)

        # *** Save in returns array ***
        self.lista_devoluciones = self.lista_devoluciones << [referencia_adeudo, codigo_rechazo, importe_adeudo,
                                                              fecha_cobro, referencia_mandato, fecha_firma_mandato,
                                                              concepto, nombre_deudor, cuenta_deudor,
                                                              id_bill, codigo_cliente]
      end
    end # read_xml
  end
end
