class SlackController < ApplicationController

  def redirect_uri

    # call oauth API
    # get code and make request

    response = HTTParty.get("https://slack.com/api/oauth.access?client_id=3110874209.35282360436&client_secret=69933a9e160d3c06da5f5276cedafe43&code=#{params[:code]}")
    puts JSON.parse(response.body)

    # {"ok"=>true, "access_token"=>"xoxp-4592131850-4592131860-35296188357-5ae4f8cc33", "scope"=>"identify,bot,commands,incoming-webhook", "user_id"=>"U04HE3VRA", "team_name"=>"Miami Tech", "team_id"=>"T04HE3VR0", "incoming_webhook"=>{"channel"=>"#emerge", "channel_id"=>"C118AHJ6Q", "configuration_url"=>"https://miamitech.slack.com/services/B118MV196", "url"=>"https://hooks.slack.com/services/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"}, "bot"=>{"bot_user_id"=>"U118PBGKF", "bot_access_token"=>"xoxb-35295390661-3xthgXmOaFBnuEoAHV25JPhT"}}
  end

end
