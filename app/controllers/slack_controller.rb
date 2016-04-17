class SlackController < ApplicationController

  def authorize
    redirect_to "https://slack.com/oauth/authorize?scope=identify,bot,incoming-webhook,commands,chat:write:user,chat:write:bot&client_id=3110874209.35282360436&redirect_uri=#{ENV['SLACK_REDIRECT_URI']}"
  end

  def redirect_uri
    redirect = ENV['SLACK_REDIRECT_URI']
    client_id = ENV['SLACK_CLIENT_ID']
    client_secret = ENV['SLACK_CLIENT_SECRET']

    response = HTTParty.get("https://slack.com/api/oauth.access?client_id=#{client_id}&client_secret=#{client_secret}&code=#{params[:code]}&redirect_uri=#{redirect}")
    parsed_body = JSON.parse(response.body)
    p "parsed_body: #{parsed_body}"

    slack_team = SlackTeam.new(
      ok: parsed_body['ok'], 
      access_token: parsed_body['access_token'],
      scope: parsed_body['scope'], 
      slack_user_id: parsed_body['user_id'],
      team_name: parsed_body['team_name'], 
      team_id: parsed_body['team_id'],
      channel: parsed_body['incoming_webhook']['channel'], 
      channel_id: parsed_body['incoming_webhook']['channel_id'],
      configuration_url: parsed_body['incoming_webhook']['configuration_url'], 
      url: parsed_body['incoming_webhook']['url'],
      bot_user_id: parsed_body['bot']['bot_user_id'], 
      bot_access_token: parsed_body['bot']['bot_access_token']
    )

    if slack_team.save
      p "Success!"
    else
      p "What we have here is...failure to authenticate."
    end

    p slack_team
    # {"ok"=>true, "access_token"=>"xoxp-4592131850-4592131860-35296188357-5ae4f8cc33", 
    # "scope"=>"identify,bot,commands,incoming-webhook", "user_id"=>"U04HE3VRA", "team_name"=>"Miami Tech", 
    #"team_id"=>"T04HE3VR0", "incoming_webhook"=>{"channel"=>"#emerge", "channel_id"=>"C118AHJ6Q", 
    #"configuration_url"=>"https://miamitech.slack.com/services/B118MV196", "url"=>"https://hooks.slack.com/services/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"},
    # "bot"=>{"bot_user_id"=>"U118PBGKF", "bot_access_token"=>"xoxb-35295390661-3xthgXmOaFBnuEoAHV25JPhT"}}
    render text: 'Success'
  end

  def command
    text = params[:text]
    slack_team = SlackTeam.find_by(team_id: params[:team_id])

    from_user = slack_team.users.where(
      slack_user_id: params[:user_id]
    ).first_or_create(
      slack_username: params[:user_name]
    )

    to_slack_username = text.split(' ')[0]
    amount = text.split(' ')[1]

    to_user = slack_team.users.where(
      slack_username: to_slack_username.gsub('@', ''),
      slack_team_id: slack_team.id
    )    

    if to_user.count == 0
      no_user = true
    else
      no_user = false
    end

    if not text.split(' ')[0].include?('@')
      render text: "Please use the format: /visapay @user $X"
      return
    elsif text.split(' ')[0] == "@setup"
      cc_info = text.split(' ')

      user = User.find_by(slack_username: params[:user_name])

      card = Card.new(
        user_id: user.id,
        card_number: cc_info[1],
        expiration: cc_info[2],
        csv: cc_info[3]
      )

      if card.save
        text = "You successfully added a card."
        owed = Payment.where(to_username: "@#{from_user.slack_username}")
        
        unless owed.count == 0
          owed.to_a.each do |payment|
            payment.to_user_id = from_user.id
            payment.to_card_id = card.id
            payment.status = "pending"
            if payment.save
              response = Visa::Funds.pull
              if response["approvalCode"].present?
                Visa::Funds.push
              end
            end
          end
        end
      else
        text = "We weren't able to save your card."
      end

      SlackTeam.query_stuffs(slack_team.access_token, params[:user_name], text)
      render text: text
    elsif text.split(' ')[0] == "@all" # all payments for a user
      text = ""
      text << SlackTeam.paid_history(from_user.id)
      text << SlackTeam.received_payments(from_user.id)
      
      SlackTeam.query_stuffs(slack_team.access_token, from_user.slack_username, text)
      render text: text

    elsif text.split(' ')[0] == "@create_event"
      create_event = Event.new(user_id: from_user.id)
      text.split('|')[1] = create_event.description
      text.split('|')[2] = create_event.amount_owed
      text.split('|')[3] = create_event.payment_to
      create_event.save
      # event = Event.new(amount_owed: amount_owed, payment_to: payment_to, description: description)
# text = "xxx"
# from_user.slack_username, text
# render text: text
   
    elsif text.split(' ')[0] == "@received" # see only received
      text = SlackTeam.received_payments(from_user.id)
      SlackTeam.query_stuffs(slack_team.access_token, from_user.slack_username, text)
      render text: text
    elsif text.split(' ')[0] == "@paid" # see all paid
      text = SlackTeam.paid_history(from_user.id)
      SlackTeam.query_stuffs(slack_team.access_token, from_user.slack_username, text)
      render text: text
    elsif text.split(' ')[0] == "@paid_to"
      text_2 = ""
      total = 0
      paid_to = text.split(' ')[1]
      payments = Payment.where(to_username: paid_to)
      unless paid_to.blank?
        user = User.find_by(slack_username: paid_to.gsub('@', ''))
      end
      unless payments.blank? || user.blank?
        payments.each do |payment|
          text_2 << "You paid @#{user.slack_username} $#{payment.amount} on #{payment.created_at.strftime('%m-%d-%Y')} \n"
          total += payment.amount
        end
      end
      unless user.blank?
        text_2 << "You paid @#{user.slack_username} a total of: $#{total.to_s}"
      end
      SlackTeam.query_stuffs(slack_team.access_token, from_user.slack_username, text_2)
      render text: text_2

    elsif text.split(' ')[0] == "@paid_from"

    elsif from_user.cards.count == 0
      text = "Setup your account by entering /visapay @setup CC# expiration csv"
      SlackTeam.query_stuffs(slack_team.access_token, params[:user_name], text)
      render text: text
    elsif no_user
      from_card_id = from_user.cards.last.id
      
      user = User.where(slack_username: to_slack_username, slack_team_id: slack_team.id)
      payment = Payment.new(
        from_user_id: from_user.id,
        to_username: to_slack_username,
        from_card_id: from_card_id,
        amount: amount
      )
      if payment.save
        p "payment saved: #{payment.inspect}"
      else
        p "payment didn't save"
      end

      text = "Yo! @#{from_user.slack_username} wants to send you money. Setup your account by entering /visapay @setup CC# expiration csv(123)."
      SlackTeam.query_stuffs(slack_team.access_token, to_slack_username, text)
      render text: text
    else
      p "to_user.last.cards.last.id: #{to_user.last.cards.last.id}"
      payment = Payment.new(
        from_user_id: from_user.id, 
        to_user_id: to_user.first.id,
        from_card_id: from_user.cards.last.id,
        to_card_id: to_user.last.cards.last.id,
        to_username: to_slack_username,
        amount: amount
      )

      if payment.save
        p "we saved a payment"
        response = Visa::Funds.pull
        if response["approvalCode"].present?
          Visa::Funds.push
          p "pull response: #{response}"

          text = "Payment to #{to_slack_username} from @#{from_user.slack_username} is pending"
          SlackTeam.query_stuffs(slack_team.access_token, to_slack_username, text)
          SlackTeam.payment_succeeded_message(slack_team.access_token, to_slack_username, from_user.slack_username, amount)
          text_2 = "success!"
        else
          p "#{'!'*20}"
          p "payment api call failed"
          p "#{'!'*20}"
          text_2 = "failure"
        end
      else
        p "payment didn't save"
        text_2 = "Failure"
      end

      render text: text_2
    end
  end
end
