module Ag2Gest
  class SepaOrder
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


    def initialize(client_payments)
      # Receive unconfirmed payments to write
      @client_payments = client_payments

      # Initialize Builder
      @xml = Builder::XmlMarkup.new(:indent => 2)
      @xml.instruct!

      # Initialize attributes default value
      self.fecha_firma_mandato = '2009-10-31'
      self.numero_total_adeudos = @client_payments.count
      self.importe_total = @client_payments.sum('amount+surcharge')
    end

    def write_xml
      @xml.Document(xmlns: "urn:iso:std:iso:20022:tech:xsd:pain.008.001.02") do
        @xml.CstmrDrctDbtInitn do
          @xml.GrpHdr do
            @xml.MsgId(self.identificacion_fichero)
            @xml.CreDtTm(self.fecha_hora_confeccion)
            @xml.NbOfTxs(self.numero_total_adeudos)
            @xml.CtrlSum(self.importe_total)
            @xml.InitgPty do
              @xml.Nm(self.nombre_presentador)
              @xml.Id do
                @xml.OrgId do
                  @xml.Othr do
                    @xml.Id(self.identificacion_presentador)
                  end
                end
              end
            end
          end # @xml.GrpHdr
          @xml.PmtInf do
            @xml.PmtInfId(self.identificacion_info_pago)
            @xml.PmtMtd(METODO_PAGO)
            @xml.BtchBookg(INDICADOR_APUNTE_CUENTA)
            @xml.PmtTpInf do
              @xml.SvcLvl do
                @xml.Cd(SIEMPRE_SEPA)
              end
              @xml.LclInstrm do
                @xml.Cd(self.tipo_esquema)
              end
            end
            @xml.SeqTp(SECUENCIA_ADEUDO)
          end # @xml.PmtInf
        end # @xml.CstmrDrctDbtInitn
      end # @xml.Document do

      # Loop thru payments
      @client_payments.each do |cp|
      end # @client_payments.each
    end

    def read_xml
      @xml
    end
  end
end
