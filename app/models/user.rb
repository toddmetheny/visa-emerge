# t.integer  "slack_team_id"
# t.string   "slack_user_id"
# t.string   "slack_username"

class User < ActiveRecord::Base
  belongs_to :slack_team

  validates_presence_of :slack_team_id, :slack_user_id, :slack_username
  
end
