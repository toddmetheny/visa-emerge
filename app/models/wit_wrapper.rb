class WitWrapper < ActiveRecord::Base

  def self.first_entity_value(entities, entity)
    return nil unless entities.has_key? entity
    val = entities[entity][0]['value']
    return nil if val.nil?
    return val.is_a?(Hash) ? val['value'] : val
  end


  def self.run_wit
    access_token = 'M6M7UDJDOG5Y6GQMDN5VNV5Z4W5W7S4G'

    actions = {
      :say => -> (session_id, context, msg) {
        # p '----msg----'
        # p msg
      },
      :merge => -> (session_id, context, entities, msg) {
        # p '----context----'
        # puts context
        amount = first_entity_value entities, 'amount_of_money'
        context['amount'] = amount unless amount.nil?

        contact = first_entity_value entities, 'contact'
        context['contact'] = contact unless contact.nil?

        creditcard_number = first_entity_value entities, 'creditcard_number'
        context['creditcard_number'] = creditcard_number unless creditcard_number.nil?

        expiration_date = first_entity_value entities, 'datetime'
        context['expiration_date'] = expiration_date unless expiration_date.nil?

        security_number = first_entity_value entities, 'number'
        context['security_number'] = security_number unless security_number.nil?

        return context
      },
      :error => -> (session_id, context, error) {
        p '----error----'
        p error.message
      },
      :sendMoney => -> (session_id, context) {
        puts "Sending #{context['contact']} $#{context['amount']}"
        return context
      },
      :storeCC => -> (session_id, context) {
        puts "Storing CC #{context['creditcard_number']} #{context['expiration_date']} #{context['security_number']}"
        return context
      },
      :transactionHistory => -> (session_id, context) {
        puts "Transaction history"
        return context
      }
    }
    client = Wit.new access_token, actions

    session_id = 'my-user-id-42'

    puts 'What is your credit card number?'
    response_1 = client.run_actions session_id, '4242424242424242', {}
    response_2 = client.run_actions session_id, 'september 2020', response_1
    response_3 = client.run_actions session_id, '2033', response_2

    puts '-------cc response-----'
    p response_3

    response_1 = client.run_actions session_id, 'What is my transaction history?', {}
    p response_1

  end
end
