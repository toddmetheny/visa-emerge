class Message < ActiveRecord::Base

  def test

    require "slack"

    Slack.configure do |config|
      config.token = "YOUR_TOKEN"
    end

    Slack.auth_test
    
  end


end