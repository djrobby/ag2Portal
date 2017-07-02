module Ag2Gest
  class SepaOrder
    attr_accessor :identificacion_fichero
    attr_accessor :fecha_hora_confeccion
    attr_accessor :nombre_presentador
    attr_accessor :identificacion_presentador
    attr_accessor :identificacion_info_pago
    attr_accessor :metodo_pago
    attr_accessor :indicador_apunte_cuenta
    attr_accessor :siempre_sepa
    attr_accessor :tipo_esquema
    attr_accessor :secuencia_adeudo

    def initialize(client_payments)
      # Receive unconfirmed payments to write
      @client_payments = client_payments

      # Initialize Builder
      @xml = Builder::XmlMarkup.new(:indent => 2)
      @xml.instruct!
    end

    def write_xml
      @xml.Document(xmlns: "urn:iso:std:iso:20022:tech:xsd:pain.008.001.02") do
        @xml.CstmrDrctDbtInitn do
          @xml.GrpHdr do
            @xml.MsgId(self.identificacion_fichero)
            @xml.CreDtTm(self.fecha_hora_confeccion)
            @xml.NbOfTxs(@client_payments.count)
            @xml.CtrlSum(@client_payments.sum('amount+surcharge'))
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
            @xml.PmtMtd(self.metodo_pago)
            @xml.BtchBookg(self.indicador_apunte_cuenta)
            @xml.PmtTpInf do
              @xml.SvcLvl do
                @xml.Cd(self.siempre_sepa)
              end
              @xml.LclInstrm do
                @xml.Cd(self.tipo_esquema)
              end
            end
            @xml.SeqTp(self.secuencia_adeudo)
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
