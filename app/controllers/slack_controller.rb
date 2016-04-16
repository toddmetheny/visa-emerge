class SlackController < ApplicationController

  def authorize
    redirect_to "https://slack.com/oauth/authorize?scope=identify,bot,incoming-webhook&client_id=3110874209.35282360436&redirect_uri=#{ENV['SLACK_REDIRECT_URI']}"
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

    # messages = Queue.new # this is like redis or zero-mq, but it's dead simple.
    #                        # See also: http://ruby-doc.org/core-2.1.5/Queue.html

    # # slack client thread, which will only forwards messages to the other
    # # thread


    # # first_url = SlackRTM.get_url(token: slack_team.access_token) # get one on https://api.slack.com/web#basics
    # # puts first_url.inspect
    
    # # second_url = SlackRTM.get_url token: slack_team.bot_access_token # get one on https://api.slack.com/web#basics
    # # puts second_url.inspect

    # url = JSON.parse(HTTParty.post("https://slack.com/api/rtm.start?token=#{slack_team.access_token}").body)['url']
    # puts url.inspect

    # t = Thread.new do

    #   client = SlackRTM::Client.new websocket_url: URI(url)
    #   client.on(:message) do |data|
    #     if data['type'] == 'message'
    #       messages << data
    #     end
    #   end
    #   client.main_loop # be careful, this never returns. That's why you need to thread.
    # end
    # t.abort_on_exception = true # will notify us if an exception happens

    # t = Thread.new do
    #   loop do
    #     msg = messages.pop
    #     # do something with the slack message. Like storing in db, if you want to log
    #     puts msg.class # => Hash
    #     p msg     # => {type: 'message', user: 'U13131', channel: 'C121212', text: 'Hello world !'}
    #               # see also: https://api.slack.com/events/message
    #   end
    # end
    # t.abort_on_exception = true # will notify us if an exception happens

    p slack_team
    # {"ok"=>true, "access_token"=>"xoxp-4592131850-4592131860-35296188357-5ae4f8cc33", 
    # "scope"=>"identify,bot,commands,incoming-webhook", "user_id"=>"U04HE3VRA", "team_name"=>"Miami Tech", 
    #"team_id"=>"T04HE3VR0", "incoming_webhook"=>{"channel"=>"#emerge", "channel_id"=>"C118AHJ6Q", 
    #"configuration_url"=>"https://miamitech.slack.com/services/B118MV196", "url"=>"https://hooks.slack.com/services/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"},
    # "bot"=>{"bot_user_id"=>"U118PBGKF", "bot_access_token"=>"xoxb-35295390661-3xthgXmOaFBnuEoAHV25JPhT"}}
    render text: 'Success'
  end

  def command

    # "team_id"=>"T04HE3VR0", 
    # "team_domain"=>"miamitech", 
    # "channel_id"=>"D04HE3W1G", 
    # "channel_name"=>"directmessage", 
    # "user_id"=>"U04HE3VRA", 
    # "user_name"=>"alain", 
    # "command"=>"/visapay", 
    # "text"=>"testing hahaha"

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
