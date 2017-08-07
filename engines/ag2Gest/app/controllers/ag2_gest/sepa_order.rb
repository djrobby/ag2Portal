module Ag2Gest
  class SepaOrder
    include ModelsModule

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
    attr_accessor :time_now

    def initialize(client_payments)
      # Receive unconfirmed payments to write
      @client_payments = client_payments

      # Initialize Builder
      @xml = Builder::XmlMarkup.new(:indent => 2)
      @xml.instruct!

      # Initialize attribute default values
      self.fecha_firma_mandato = '2009-10-31'
      self.numero_total_adeudos = @client_payments.count
      self.importe_total = en_formatted_number_without_delimiter(@client_payments.sum('amount+surcharge'), 2)
    end

    #
    # *** Writes & returns XML stream
    #
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
              @xml.SeqTp(SECUENCIA_ADEUDO)
            end # @xml.PmtTpInf
            @xml.ReqdColltnDt(self.fecha_cobro)
            @xml.Cdtr do
              @xml.Nm(self.nombre_presentador)
              @xml.PstlAdr do
                @xml.Ctry(PAIS)
              end
            end # @xml.Cdtr
            @xml.CdtrAcct do
              @xml.Id do
                @xml.IBAN(self.cuenta_acreedor)
              end
              @xml.Ccy(MONEDA)
            end # @xml.CdtrAcct
            @xml.CdtrAgt do
              @xml.FinInstnId do
                @xml.BIC(BIC)
              end
            end # @xml.CdtrAgt
            @xml.ChrgBr(GASTOS)
            @xml.CdtrSchmeId do
              @xml.Id do
                @xml.PrvtId do
                  @xml.Othr do
                    @xml.Id(self.identificacion_presentador)
                    @xml.SchmeNm do
                      @xml.Prtry(SIEMPRE_SEPA)
                    end
                  end
                end
              end
            end # @xml.CdtrSchmeId
            #
            # Loop thru payments
            #
            i = 0
            @client_payments.each do |cp|
              # Look for data & Set attribute values
              anombre = ''
              adirecc = ''
              i += 1
              if !cp.subscriber.blank?
                anombre = cp.sanitized_subscriber_name
                adirecc = cp.sanitized_subscriber_address
              else
                anombre = cp.sanitized_client_name
                adirecc = cp.sanitized_client_address
              end
              self.concepto = "FRA.AGUA " + cp.bill.real_no_unformatted + " " + cp.bill.billing_period_code + " " + adirecc + " " + anombre
              self.entidad_deudor = cp.client_bank_account_swift.ljust(11)
              self.importe_adeudo = en_formatted_number_without_delimiter(cp.total, 2)
              self.referencia_mandato = cp.client_bank_account_refere
              self.fecha_firma_mandato = cp.client_bank_account_start
              self.identificacion_instruccion = self.time_now.strftime("%Y%m%d%H%M%S%L") + i.to_s.rjust(4,'0')
              self.nombre_deudor = cp.sanitized_client_bank_account_holder
              self.cuenta_deudor = cp.client_bank_account_iban
              # Max. 35: invoice_no 16 + receipt_no 6 + date 12 + 1
              self.referencia_adeudo = cp.bill.full_id + cp.receipt_no.rjust(6,'0') + self.time_now.strftime("%Y%m%d%H%M") + "0"
              # *** Write payment line ***
              @xml.DrctDbtTxInf do
                @xml.PmtId do
                  @xml.InstrId(self.identificacion_instruccion)
                  @xml.EndToEndId(self.referencia_adeudo)
                end # @xml.PmtId
                @xml.InstdAmt({ Ccy: MONEDA }, self.importe_adeudo)
                @xml.DrctDbtTx do
                  @xml.MndtRltdInf do
                    @xml.MndtId(self.referencia_mandato)
                    @xml.DtOfSgntr(self.fecha_firma_mandato)
                    @xml.AmdmntInd('false')
                  end
                end # @xml.DrctDbtTx
                @xml.DbtrAgt do
                  @xml.FinInstnId do
                    @xml.Othr do
                      @xml.Id(BIC)
                    end
                  end
                end # @xml.DbtrAgt
                @xml.Dbtr do
                  @xml.Nm(self.nombre_deudor)
                end # @xml.Dbtr
                @xml.DbtrAcct do
                  @xml.Id do
                    @xml.IBAN(self.cuenta_deudor)
                  end
                end # @xml.DbtrAcct
                @xml.RmtInf do
                  @xml.Ustrd(self.concepto)
                end # @xml.RmtInf
              end # @xml.DrctDbtTxInf
            end # @client_payments.each
          end # @xml.PmtInf
        end # @xml.CstmrDrctDbtInitn
      end # @xml.Document do
    end # write_xml

    #
    # *** Returns current XML stream
    #
    def read_xml
      @xml
    end
  end
end
