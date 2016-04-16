module Visa
  class Funds

    attr_reader :error_message, :response

    def initialize(options={})
      @response = options[:response]
      @error_message = options[:error_message]
    end

    def self.create_body(params)

      # TODO figure out
      # systemsTraceAuditNumber = 300259
      # retrievalReferenceNumber = '407509300259'
      # acquiringBin = 409999

      # CC Number
      # senderPrimaryAccountNumber = '4005520000011126'
      # senderCardExpiryDate = '2017-03'
      # amount = '112.00'

      if params[:acquirerCountryCode].blank?
        params[:acquirerCountryCode] = '101'
      end

      if params[:senderCurrencyCode].blank?
        params[:senderCurrencyCode] = 'USD'
      end

      # Transaction date time
      date = Time.new
      date = date.strftime "%Y-%m-%dT%H:%M:%S"
      params[:localTransactionDateTime] = date

      body = { businessApplicationId: "AA",
                merchantCategoryCode: 6012,
                pointOfServiceCapability: {
                  posTerminalType: "4",
                  posTerminalEntryCapability: "2"
                },
                feeProgramIndicator: "123",
                systemsTraceAuditNumber: params[:systemsTraceAuditNumber],
                retrievalReferenceNumber: params[:retrievalReferenceNumber],
                foreignExchangeFeeTransaction: "10.00",
                cardAcceptor: {
                  name: "Acceptor 1",
                  terminalId: "365539",
                  idCode: "VMT200911026070",
                  address: {
                    state: "CA",
                    county: "081",
                    country: "USA",
                    zipCode: "94404"
                  }
                },
                magneticStripeData: {
                  track1Data: "1010101010101010101010101010"
                },
                senderPrimaryAccountNumber: params[:senderPrimaryAccountNumber],
                senderCurrencyCode: params[:senderCurrencyCode],
                surcharge: "2.00",
                localTransactionDateTime: params[:localTransactionDateTime],
                senderCardExpiryDate: params[:senderCardExpiryDate],
                pinData: {
                  pinDataBlock: "1cd948f2b961b682",
                  securityRelatedControlInfo: {
                    pinBlockFormatCode: 1,
                    zoneKeyIndex: 1
                  }
                },
                cavv: "0000010926000071934977253000000000000000",
                pointOfServiceData: {
                  panEntryMode: "90",
                  posConditionCode: "0",
                  motoECIIndicator: "0"
                },
                acquiringBin: params[:acquiringBin],
                acquirerCountryCode: params[:acquirerCountryCode],
                amount: params[:amount]
              }

      return body.to_json;
    end

    def self.pull(payload_data)


      payload_data = {
        systemsTraceAuditNumber: 300259,
        retrievalReferenceNumber: '407509300259',
        senderPrimaryAccountNumber: '4005520000011126',
        senderCardExpiryDate: '2017-03',
        acquiringBin: 409999,
        amount: '112.00'
      }

      resource_path = 'fundstransfer/v1/pullfundstransactions/'
      url = 'https://sandbox.api.visa.com/visadirect/' + resource_path
      headers = {'content-type'=> 'application/json', 'accept'=> 'application/json'}

      key_path = '/Users/josecasanova/Documents/programming/personal/key_visa-emerge-2.pem'
      cert_path = '/Users/josecasanova/Documents/programming/personal/cert2.pem'
      user_id = 'W3PGA6DZ3XLODFJ912UR21063doIwQtfQIy90q4W9aNgdyUIE'
      password = '01Zm9KxdtSBokVqXgVYLepqY6B0'

      begin
        response = RestClient::Request.execute(
            :method => :post,
            :url => url,
            :headers => headers,
            :payload => Visa::Funds.create_body(payload_data),
            :user => user_id,
            :password => password,
            :ssl_client_key => OpenSSL::PKey::RSA.new(File.read(key_path)),
            :ssl_client_cert =>  OpenSSL::X509::Certificate.new(File.read(cert_path))
        )

        puts response
      rescue RestClient::ExceptionWithResponse => e
        response = e.response
        puts response
      end

      return response
    end
  end
end