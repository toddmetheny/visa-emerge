class Message < ActiveRecord::Base

  def self.test

    # require "slack"

    slack_team = SlackTeam.last

    # Slack.configure do |config|
    #   config.token = slack_team.access_token
    # end

    # slack_client = Slack.client

    # slack_client.chat_postMessage({
    #   channel: '#emerge',
    #   text: 'testing from API',
    #   username: 'visapay',
    #   as_user: true
    # })

    query = {
      token: slack_team.access_token,
      channel: '@alain',
      text: 'testing 123',
      username: 'visapay',
      as_user: true
    }.to_query



    response = HTTParty.get("https://slack.com/api/chat.postMessage?#{query}")

    response.body

  end


end