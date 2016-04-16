class SlackController < ApplicationController

  def authorize
    redirect_to "https://slack.com/oauth/authorize?scope=incoming-webhook,commands,bot&client_id=3110874209.35282360436&state=read,post,client&redirect_uri=#{ENV['SLACK_REDIRECT_URI']}"
  end

  def redirect_uri
    
    redirect = ENV['SLACK_REDIRECT_URI']
    # call oauth API
    # get code and make request
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
      p "#{'!'*20}"
      p "created new slack team"
      p "#{'!'*20}"
    end

    p slack_team
    # {"ok"=>true, "access_token"=>"xoxp-4592131850-4592131860-35296188357-5ae4f8cc33", 
    # "scope"=>"identify,bot,commands,incoming-webhook", "user_id"=>"U04HE3VRA", "team_name"=>"Miami Tech", 
    #"team_id"=>"T04HE3VR0", "incoming_webhook"=>{"channel"=>"#emerge", "channel_id"=>"C118AHJ6Q", 
    #"configuration_url"=>"https://miamitech.slack.com/services/B118MV196", "url"=>"https://hooks.slack.com/services/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"},
    # "bot"=>{"bot_user_id"=>"U118PBGKF", "bot_access_token"=>"xoxb-35295390661-3xthgXmOaFBnuEoAHV25JPhT"}}
    render text: 'Success'
  end

end
