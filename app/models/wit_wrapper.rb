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
        p '----msg----'
        p msg
      },
      :merge => -> (session_id, context, entities, msg) {
        p '----context----'
        puts context
        amount = first_entity_value entities, 'amount_of_money'
        context['amount'] = amount unless amount.nil?

        contact = first_entity_value entities, 'contact'
        context['contact'] = contact unless contact.nil?

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
    }
    client = Wit.new access_token, actions

    session_id = 'my-user-id-42'
    response = client.run_actions session_id, 'Send @joe $5', {}

    p '----response----'
    p response

    # session_id = 'my-user-id-42'
    # resp = client.message 'Send @todd $5!'
    # return resp
    # p "Yay, got Wit.ai response: #{resp}"
    # client.run_actions session_id, 'Send @todd $5!', {}

    # resp = client.converse 'my-user-session-42', 'Send @todd $5', {}
    # p "Yay, got Wit.ai response: #{resp}"

    # session = 'my-user-session-42'
    # context0 = {}
    # context1 = client.run_actions session, 'Send @todd $5', context0
    # p "The session state is now: #{context1}"
  end
end
