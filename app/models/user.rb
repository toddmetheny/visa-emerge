# t.integer  "slack_team_id"
# t.string   "slack_user_id"
# t.string   "slack_username"

class User < ActiveRecord::Base
  belongs_to :slack_team
  has_many :cards
  has_many :payments

  validates_presence_of :slack_team_id, :slack_username

  validates :slack_username, uniqueness: {scope: :slack_team_id}

end
