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

    attr_accessor :identificacion_fichero
    attr_accessor :fecha_hora_confeccion
    attr_accessor :numero_total_adeudos
    attr_accessor :importe_total
    attr_accessor :nombre_presentador
    attr_accessor :identificacion_presentador
    attr_accessor :tipo_esquema
    attr_accessor :identificacion_info_pago
    attr_accessor :fecha_cobro
    attr_accessor :cuenta_acreedor
    attr_accessor :identificacion_instruccion
    attr_accessor :referencia_adeudo
    attr_accessor :importe_adeudo
    attr_accessor :referencia_mandato
    attr_accessor :fecha_firma_mandato
    attr_accessor :nombre_deudor
    attr_accessor :cuenta_deudor
    attr_accessor :entidad_deudor
    attr_accessor :concepto
    attr_accessor :time_now


    def initialize(file_to_process)
      # Open XML file
      self.fichero = File.new(file_to_process)
      # Initialize XML Document
      @doc = Document.new self.fichero
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
      self.fecha_hora_confeccion = @doc.get_elements('//CreDtTm')[0].text
      #
      # Loop thru rejections (DrctDbtTxInf)
      #
      @doc.elements.each('//DrctDbtTxInf') do |e|
        importe = e.elements['InstdAmt'].text.to_d
      end

      @doc
    end # read_xml
  end
end
