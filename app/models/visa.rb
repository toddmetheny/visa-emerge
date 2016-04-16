module Visa
  class Funds

    attr_reader :error_message, :response

    def initialize(options={})
      @response = options[:response]
      @error_message = options[:error_message]
    end

    def self.create_pull_body(params)

      # TODO figure out
      systemsTraceAuditNumber = 300259
      acquiringBin = 409999
      retrievalReferenceNumber = '407509300259'

      # CC Number
      senderPrimaryAccountNumber = '4005520000011126'
      senderCardExpiryDate = '2017-03'
      amount = '112.00'

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

      body = {  systemsTraceAuditNumber: systemsTraceAuditNumber,
                retrievalReferenceNumber: retrievalReferenceNumber,
                localTransactionDateTime: params[:localTransactionDateTime],
                acquiringBin: acquiringBin,
                acquirerCountryCode: params[:acquirerCountryCode],
                senderPrimaryAccountNumber: senderPrimaryAccountNumber,
                senderCardExpiryDate: senderCardExpiryDate,
                senderCurrencyCode: params[:senderCurrencyCode],
                amount: amount,
                businessApplicationId: 'AA',
                cardAcceptor: {address: { country: 'USA',
                                          county: 'San Mateo',
                                          state: 'CA',
                                          zipCode: '994404'
                                        },
                              idCode: 'ABCD1234ABCD123',
                              name: 'Visa Inc. USA-Foster City',
                              terminalId: 'ABCD1234'
                              }
              }
      return body.to_json;
    end

    def self.pull

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
            :payload => Visa::Funds.create_pull_body(payload_data),
            :user => user_id,
            :password => password,
            :ssl_client_key => OpenSSL::PKey::RSA.new(File.read(key_path)),
            :ssl_client_cert =>  OpenSSL::X509::Certificate.new(File.read(cert_path))
        )

      rescue RestClient::ExceptionWithResponse => e
        response = e.response
      end

      puts JSON.parse(response)
      return JSON.parse(response)
    end

    # def self.create_push_body(params)

    #   # TODO figure out
    #   # systemsTraceAuditNumber = 300259
    #   # retrievalReferenceNumber = '407509300259'
    #   # acquiringBin = 409999

    #   # CC Number
    #   # senderPrimaryAccountNumber = '4005520000011126'
    #   # senderCardExpiryDate = '2017-03'
    #   # amount = '112.00'

    #   if params[:acquirerCountryCode].blank?
    #     params[:acquirerCountryCode] = '101'
    #   end

    #   # Transaction date time
    #   date = Time.new
    #   date = date.strftime "%Y-%m-%dT%H:%M:%S"
    #   params[:localTransactionDateTime] = date

    #   body = {
    #     systemsTraceAuditNumber:
    #     retrievalReferenceNumber:
    #     localTransactionDateTime: params[:localTransactionDateTime],
    #     acquiringBin:
    #     acquirerCountryCode:
    #     senderReference:
    #     senderAccountNumber: params[:acquirerCountryCode],
    #     transactionCurrencyCode:
    #     senderName:
    #     senderAddress:
    #     senderCity:
    #     senderStateCode:
    #     recipientPrimaryAccountNumber:
    #     recipientName:
    #     amount:
    #     businessApplicationId:
    #     merchantCategoryCode:
    #     transactionIdentifier:
    #     sourceOfFundsCode:
    #     cardAcceptor:
    #   }
    #   return body.to_json;
    # end

    # def self.push(payload_data)

    #   systemsTraceAuditNumber
    #   retrievalReferenceNumber
    #   localTransactionDateTime
    #   acquiringBin
    #   acquirerCountryCode
    #   senderReference
    #   senderAccountNumber
    #   transactionCurrencyCode
    #   senderName
    #   senderAddress
    #   senderCity
    #   senderStateCode
    #   recipientPrimaryAccountNumber
    #   recipientName
    #   amount
    #   businessApplicationId
    #   merchantCategoryCode
    #   transactionIdentifier
    #   sourceOfFundsCode
    #   cardAcceptor

    #   resource_path = 'fundstransfer/v1/pushfundstransactions/'
    #   url = 'https://sandbox.api.visa.com/visadirect/' + resource_path
    #   headers = {'content-type'=> 'application/json', 'accept'=> 'application/json'}

    #   key_path = '/Users/josecasanova/Documents/programming/personal/key_visa-emerge-2.pem'
    #   cert_path = '/Users/josecasanova/Documents/programming/personal/cert2.pem'
    #   user_id = 'W3PGA6DZ3XLODFJ912UR21063doIwQtfQIy90q4W9aNgdyUIE'
    #   password = '01Zm9KxdtSBokVqXgVYLepqY6B0'

    #   begin
    #     response = RestClient::Request.execute(
    #         :method => :post,
    #         :url => url,
    #         :headers => headers,
    #         :payload => Visa::Funds.create_body(payload_data),
    #         :user => user_id,
    #         :password => password,
    #         :ssl_client_key => OpenSSL::PKey::RSA.new(File.read(key_path)),
    #         :ssl_client_cert =>  OpenSSL::X509::Certificate.new(File.read(cert_path))
    #     )

    #   rescue RestClient::ExceptionWithResponse => e
    #     response = e.response
    #   end

    #   puts JSON.parse(response)
    #   return JSON.parse(response)
    # end

  end
end