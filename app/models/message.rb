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
      channel: '@toddmetheny',
      text: 'testing',
      username: 'visapay',
      as_user: false
    }.to_query



    response = HTTParty.get("https://slack.com/api/chat.postMessage?#{query}")

    response.body

  end


end