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

  # "team_id"=>"T04HE3VR0", 
  # "team_domain"=>"miamitech", 
  # "channel_id"=>"D04HE3W1G", 
  # "channel_name"=>"directmessage", 
  # "user_id"=>"U04HE3VRA", 
  # "user_name"=>"alain", 
  # "command"=>"/visapay", 
  # "text"=>"testing hahaha"
  def command
    text = params[:text]
    slack_team = SlackTeam.find_by(team_id: params[:team_id])

    p "params: #{params.inspect}"

    # get the from user or create it
    from_user = slack_team.users.where(
      slack_user_id: params[:user_id]
    ).first_or_create(
      slack_username: params[:user_name]
    )

    p "from user cards: #{from_user.cards}"

    to_slack_username = text.split(' ')[0]
    p "to_slack_username: #{to_slack_username}"
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
      # check for the existence of a to_payment_id
      cc_info = text.split(' ')

      user = User.find_by(slack_username: params[:user_name])

      card = Card.new(
        user_id: user.id,
        card_number: cc_info[1],
        expiration: cc_info[2],
        csv: cc_info[3]
      )

      # method call that runs query, creates card from response, 
      # and then returns success message to user
      if card.save
        text = "You successfully added a card."

        # on setup we're looking for payments owed to the
        # user who is setting up
        p "from username: #{from_user.slack_username}"
        owed = Payment.where(to_username: "@#{from_user.slack_username}")
        p "owed: #{owed.inspect}"
        if owed.count == 0
          p "nothing owed"
        else
          p "#{from_user.slack_username} is owed some money"
          p "payments: #{owed.count}"
          owed.to_a.each do |payment|
            p "inside payments owed loop"
            payment.to_user_id = from_user.id
            payment.to_card_id = card.id
            payment.status = "pending"
            if payment.save
              puts "payment saved"
              # make the api call to actually make the fucking payment
              # api call to make payment goes here
              # if payment succeeds, call method that tells both users
            else
              puts "payment didn't save"
            end
          end
        end
      else
        text = "We weren't able to save your card."
      end

      SlackTeam.query_stuffs(slack_team.access_token, params[:user_name], text)
      render text: text
    elsif text.split(' ')[0] == "@all"
      # return all of the payments for that user
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

      text = "Hey dude! @#{from_user.slack_username} wants to send you money. Setup your account by entering /visapay @setup CC# expiration csv(123)."
      SlackTeam.query_stuffs(slack_team.access_token, to_slack_username, text)
      render text: text
    else
      payment = Payment.new(
        from_user_id: from_user.id, 
        to_user_id: to_user.first,
        from_card_id: from_user.cards.last.id,
        to_card_id: to_user.last.cards.last.id,
        to_username: to_slack_username,
        amount: amount
      )

      if payment.save
        p "we saved a payment"


        # actually make the fucking payment
        # visa api call goes here
        # call method to update both the users
        SlackTeam.payment_succeeded_message(slack_team.access_token, to_slack_username, from_user.slack_username, amount)
      else
        p "payment didn't save"
      end

      text = "Payment to #{to_slack_username} from @#{from_user.slack_username} is pending"
      SlackTeam.query_stuffs(slack_team.access_token, to_slack_username, text)
      render text: text
    end
  end
end
