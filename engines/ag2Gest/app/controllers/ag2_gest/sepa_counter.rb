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
    attr_accessor :process_date_time
    attr_accessor :sufijo
    attr_accessor :nif
    attr_accessor :total_bills
    attr_accessor :total_amount
    attr_accessor :lista_cobros

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
        cod_reg = line[0,2]
        if cod_reg == '80'
          # Totals line
          amount = line[36,12]
          self.total_bills = line[22,6].to_i
          self.total_amount = (amount[0,10] + '.' + amount[10,2]).to_d
        elsif cod_reg == '02'
          # Header line
          self.nif = line[10,8]
          self.sufijo = line[18,3]
        else
          # Invoice charged line: Save in array
          amount = line[36,12]
          self.lista_cobros.push(bill_id: line[76,11].to_i,
                                 amount: (amount[0,10] + '.' + amount[10,2]).to_d,
                                 date: line[30,6],
                                 issuer: line[10,8],
                                 suffix: line[18,3],
                                 charge_code: line[21,1],
                                 charge_bank: line[22,4],
                                 charge_office: line[26,4],
                                 charge_id: line[48,6],
                                 ccc_bank: line[54,4],
                                 ccc_office: line[58,4],
                                 ccc_dc: line[62,2],
                                 ccc_account_no: line[64,10],
                                 debit_code: line[74,1],
                                 cancel_code: line[75,1],
                                 reference: line[76,13])
        end
      end # f.each_line
      f.close
    end # read_txt
  end
end
