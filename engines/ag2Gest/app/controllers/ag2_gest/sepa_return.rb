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
    attr_accessor :process_date_time
    attr_accessor :OrgnlMsgId
    attr_accessor :OrgnlPmtInfId
    attr_accessor :fecha_hora_confeccion
    attr_accessor :numero_total_adeudos
    attr_accessor :importe_total
    attr_accessor :sufijo
    attr_accessor :nif
    attr_accessor :fecha_devolucion
    attr_accessor :lista_devoluciones
    attr_accessor :remesa
    attr_accessor :remesa_old

    # def initialize(file_to_process)
    #   # Open XML file
    #   self.fichero = File.new(file_to_process)
    #   # Initialize XML Document
    #   @doc = Document.new self.fichero
    #   # Initialize attribute default values
    #   self.lista_devoluciones = []
    # end

    def initialize(file_content)
      # Open XML file
      self.fichero = file_content
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
      self.process_date_time = Date.parse(self.fecha_hora_confeccion[0,10]) rescue Date.today
      # fiscal id, bank suffix & date of order
      self.OrgnlMsgId = @doc.get_elements('//OrgnlMsgId')[0].text
      self.OrgnlPmtInfId = @doc.get_elements('//OrgnlPmtInfId')[0].text
      begin   # sufijo based on OrgnlPmtInfId
        self.sufijo = self.OrgnlPmtInfId[4,3]
      rescue  # sufijo based on OrgnlMsgId
        self.sufijo = self.OrgnlMsgId[22,3]
      end
      begin   # nif based on OrgnlPmtInfId
        self.nif = self.OrgnlPmtInfId[7,9]
      rescue  # nif based on OrgnlMsgId
        self.nif = self.OrgnlMsgId[25,9]
      end
      begin   # nif based on OrgnlPmtInfId
        self.fecha_devolucion = self.OrgnlPmtInfId[16,8].to_date
      rescue  # nif based on OrgnlMsgId
        self.fecha_devolucion = self.OrgnlMsgId[3,8].to_date
      end
      # Original file data
      self.numero_total_adeudos = @doc.elements['//CstmrPmtStsRpt'].elements['OrgnlPmtInfAndSts'].elements['OrgnlNbOfTxs'].text
      self.importe_total = @doc.elements['//CstmrPmtStsRpt'].elements['OrgnlPmtInfAndSts'].elements['OrgnlCtrlSum'].text
      #
      # Loop thru rejections (TxInfAndSts)
      #
      receipt_no = ''
      remesa_old = ''
      @doc.elements.each('//TxInfAndSts') do |e|
        referencia_adeudo = e.elements['OrgnlEndToEndId'].text
        codigo_rechazo = e.elements['StsRsnInf'].elements['Rsn'].elements['Cd'].text
        importe_adeudo = (e.elements['OrgnlTxRef'].elements['Amt'].elements['InstdAmt'].text.to_d) * (-1)
        fecha_cobro = e.elements['OrgnlTxRef'].elements['ReqdColltnDt'].text.to_date
        referencia_mandato = e.elements['OrgnlTxRef'].elements['MndtRltdInf'].elements['MndtId'].text
        fecha_firma_mandato = e.elements['OrgnlTxRef'].elements['MndtRltdInf'].elements['DtOfSgntr'].text.to_date
        concepto = e.elements['OrgnlTxRef'].elements['RmtInf'].elements['Ustrd'].text
        nombre_deudor = e.elements['OrgnlTxRef'].elements['Dbtr'].elements['Nm'].text
        cuenta_deudor = e.elements['OrgnlTxRef'].elements['DbtrAcct'].elements['Id'].elements['IBAN'].text
        id_bill = referencia_adeudo.first(10).to_i
        id_client_payment = referencia_adeudo[10,9].to_i
        receipt_no = referencia_adeudo[19,6]
        id_client = referencia_mandato.last(8).to_i
        remesa_old = referencia_adeudo[10,6]

        # *** Save in returns array ***
        self.lista_devoluciones.push(referencia_adeudo: referencia_adeudo,
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
      self.remesa_old = remesa_old
    end # read_xml
  end
end
