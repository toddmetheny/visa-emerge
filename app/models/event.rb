class Event < ActiveRecord::Base
  # 3110874209.35282360436
  # 69933a9e160d3c06da5f5276cedafe43
  has_many :invoices

  after_save :create_invoices

  def create_invoices
    slack_team_id = User.where(id: self.user_id).pluck(:slack_team_id).first
    slack_team = SlackTeam.find(slack_team_id)
    users = User.where(slack_team_id: slack_team_id)

    users.each do |user|
      Invoice.create(status: "unpaid", user_id: user.id, event_id: self.id)
      text = "#{self.description} and #{user.slack_username} should /visapay #{self.payment_to} $#{self.amount_owed}"
      SlackTeam.query_stuffs(slack_team.access_token, user.slack_username, text)
    end
  end
end
