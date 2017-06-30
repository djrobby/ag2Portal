module Ag2Gest
  class SepaOrder
    attr_accessor :identificacion_fichero
    attr_accessor :fecha_hora_confeccion

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
          end # @xml.GrpHdr
          # Loop thru payments
          @client_payments.each do |cp|
          end # @client_payments.each
        end # @xml.CstmrDrctDbtInitn
      end # @xml.Document do
    end

    def read_xml
      @xml
    end
  end
end
