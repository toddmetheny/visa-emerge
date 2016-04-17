module Visa
  class Funds

    attr_reader :error_message, :response

    def initialize(options={})
      @response = options[:response]
      @error_message = options[:error_message]
    end

    def self.create_pull_body(params)

      p "params: #{params.inspect}"

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

      key_path = '/Users/gilchrist/Desktop/key_sean-pay.pem'
      cert_path = '/Users/gilchrist/Desktop/cert.pem'
      user_id = 'YSR97TUDQZBUB286402521ulzFoygLwaUTKr4hPwuDc3OnLVg'
      password = 'n00lA6APZQe9Z5'

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

      return JSON.parse(response)
    end


    def self.create_push_body
      body = {
        "acquirerCountryCode": "840",
        "acquiringBin": "408999",
        "amount": "124.05",
        "businessApplicationId": "AA",
        "cardAcceptor": {
          "address": {
            "country": "USA",
            "county": "San Mateo",
            "state": "CA",
            "zipCode": "94404"
          },
          "idCode": "CA-IDCode-77765",
          "name": "Visa Inc. USA-Foster City",
          "terminalId": "TID-9999"
        },
        "localTransactionDateTime": "2016-04-16T18:06:28",
        "merchantCategoryCode": "6012",
        "pointOfServiceData": {
          "motoECIIndicator": "0",
          "panEntryMode": "90",
          "posConditionCode": "00"
        },
        "recipientName": "rohan",
        "recipientPrimaryAccountNumber": "4957030420210496",
        "retrievalReferenceNumber": "412770451018",
        "senderAccountNumber": "4653459515756154",
        "senderAddress": "901 Metro Center Blvd",
        "senderCity": "Foster City",
        "senderCountryCode": "124",
        "senderName": "Mohammed Qasim",
        "senderReference": "",
        "senderStateCode": "CA",
        "sourceOfFundsCode": "05",
        "systemsTraceAuditNumber": "451018",
        "transactionCurrencyCode": "USD",
        "transactionIdentifier": "381228649430015"
      }

      return body.to_json;
    end

    def self.push

      resource_path = 'fundstransfer/v1/pushfundstransactions/'
      url = 'https://sandbox.api.visa.com/visadirect/' + resource_path
      headers = {'content-type'=> 'application/json', 'accept'=> 'application/json'}

      key_path = '/Users/gilchrist/Desktop/key_sean-pay.pem'
      cert_path = '/Users/gilchrist/Desktop/cert.pem'
      user_id = 'YSR97TUDQZBUB286402521ulzFoygLwaUTKr4hPwuDc3OnLVg'
      password = 'n00lA6APZQe9Z5'

      begin
        response = RestClient::Request.execute(
            :method => :post,
            :url => url,
            :headers => headers,
            :payload => Visa::Funds.create_push_body,
            :user => user_id,
            :password => password,
            :ssl_client_key => OpenSSL::PKey::RSA.new(File.read(key_path)),
            :ssl_client_cert =>  OpenSSL::X509::Certificate.new(File.read(cert_path))
        )

      rescue RestClient::ExceptionWithResponse => e
        response = e.response
      end

      return JSON.parse(response)
    end

    def self.transaction
      pull = self.pull
      push = self.push

      obj = {
        pull: pull,
        push: push
      }

      return obj

    end

  end
end