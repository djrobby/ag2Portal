#require 'net/http'

module Ag2Human
  class SoapRequest
    # include ModelsModule

    # Constants
    # METODO_PAGO ||= 'DD'

    # Attributes
    attr_accessor :time_now
    attr_accessor :uri
    attr_accessor :body
    attr_accessor :response
    # attr_reader :response

    def initialize
      # Initialize attribute default values
      self.time_now = Time.now
      self.response = nil
      self.uri = 'http://81.46.192.208:81/A3satelWSEquipo.asmx'
      self.body = "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">
                    <soap12:Body>
                      <Int_Empleados_Y_Coste_Nomina xmlns=\"http://localhost/SiuReAut/Servicios/\">
                        <CodigoUsuario>API</CodigoUsuario>
                        <Password>qMqnpx4cJ4heWc</Password>
                        <CodigoCliente>48646</CodigoCliente>
                        <CodigoEmpresa>3</CodigoEmpresa>
                        <CodigoCentroTrabajo>1</CodigoCentroTrabajo>
                        <Anyo>2016</Anyo>
                        <Mes>12</Mes>
                        <TipoPaga>1</TipoPaga>
                        <Activo>1</Activo>
                      </Int_Empleados_Y_Coste_Nomina>
                    </soap12:Body>
                  </soap12:Envelope>"
    end

    #
    # *** SOAP Request
    # returns SOAP response
    #
    # puts "Response HTTP Status Code: #{res.code}"
    # puts "Response HTTP Status Message: #{res.message}"
    # puts "Response HTTP Content-Type: #{res.content-type}"
    # puts "Response HTTP Content-Length: #{res.content-length}"
    # puts "Response HTTP Response Body: #{res.body}"
    def send_request
      uri = URI(self.uri)
      # uri_encode = URI.encode(self.uri)

      # Create client
      http = Net::HTTP.new(uri.host, uri.port)

      # Create Request
      req = Net::HTTP::Post.new(uri.path)
      # Add headers
      req.add_field "Content-Type", "application/soap+xml; charset=utf-8"
      # Set body
      req.body = self.body

      # Fetch Request
      self.response = http.request(req)
      return "OK"
    rescue StandardError => e
      self.response = nil
      return "HTTP Request failed (#{e.message})"
    end # send_request

    #
    # *** Returns current XML stream
    #
    def read_xml
    end
  end
end
