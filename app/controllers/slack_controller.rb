class SlackController < ApplicationController

  def authorize
    redirect_to "https://slack.com/oauth/authorize?scope=incoming-webhook,commands,bot,chat:write:bot&client_id=3110874209.35282360436&state=read,post,client,identify,chat:write:user&redirect_uri=#{ENV['SLACK_REDIRECT_URI']}"
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
    
    # payload
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

    if not text.split(' ')[0].include?('@')
      render text: "Please use the format: /visapay @user $X"
      return
    end

    slack_team = SlackTeam.find_by(team_id: params[:team_id])

    # get the from user or create it
    from_user = slack_team.users.where(
      slack_user_id: params[:user_id]
    ).first_or_create(
      slack_username: params[:user_name]
    )

    to_slack_username = text.split(' ')[0]

    to_user = slack_team.users.where(
      slack_username: to_slack_username
    )

    if to_user.count == 0

      query = {
        token: slack_team.access_token,
        channel: to_slack_username,
        text: "Hey dude! Someone wants to send you money :D",
        username: 'visapay',
        as_user: true
      }.to_query

      response = HTTParty.get("https://slack.com/api/chat.postMessage?#{query}")

    end

    render text: "SWEET"

  end

end
