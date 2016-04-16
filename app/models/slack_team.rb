# t.boolean  "ok"
# t.string   "access_token"
# t.string   "scope"
# t.string   "slack_user_id"
# t.string   "team_name"
# t.string   "team_id"
# t.string   "channel"
# t.string   "channel_id"
# t.string   "configuration_url"
# t.string   "url"
# t.string   "bot_user_id"
# t.string   "bot_access_token"

class SlackTeam < ActiveRecord::Base

  has_many :users

  validates_presence_of :access_token, :scope, :slack_user_id, 
    :team_id, :channel, :channel_id, :configuration_url, :url, 
    :bot_user_id, :bot_access_token

  validate :successfully_authenticated

  def successfully_authenticated
    unless self.ok == true
      self.errors.add(:ok, "Response must include ok true!")
    end
  end

end
