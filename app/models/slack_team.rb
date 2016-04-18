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

  # validates_presence_of :access_token, :scope, :slack_user_id, 
  # :team_id, :channel, :channel_id, :configuration_url, :url, 
  # :bot_user_id, :bot_access_token

  # validate :successfully_authenticated

  def successfully_authenticated
    unless self.ok == true
      self.errors.add(:ok, "Response must include ok true!")
    end
  end

  def self.payment_succeeded_message(token, to_user_name, from_user_name, amount)
    text_to = "@#{from_user_name} sent you $#{amount}!"
    text_from = "You sent #{to_user_name} $#{amount}"
    query_to = {
      token: token,
      channel: to_user_name,
      text: text_to,
      username: 'VisaPay',
      as_user: false
    }.to_query

    query_from = {
      token: token,
      channel: from_user_name,
      text: text_from,
      username: 'VisaPay',
      as_user: false
    }.to_query
    message_for_to_user = HTTParty.get("https://slack.com/api/chat.postMessage?#{query_to}")
    message_for_from_user = HTTParty.get("https://slack.com/api/chat.postMessage?#{query_from}")
  end

  def self.query_stuffs(token, channel, text)
    p "inside query stuffs"
    p "channel: #{channel}"
    unless channel.include?("@")
      channel = "@#{channel}"
    end
    query = {
      token: token,
      channel: channel,
      text: text,
      username: 'VisaPay',
      as_user: false
    }.to_query

    response = HTTParty.get("https://slack.com/api/chat.postMessage?#{query}")

    puts "query stuffs response: #{response.body}"
  end

  def self.received_payments(user_id)
    text = ""
    payments_to = Payment.where(to_user_id: user_id)
    if payments_to.blank?
      text << "You haven't received any payments \n"
    else
      payments_to.each do |payment|
        other_user = User.select(:id, :slack_username).where(id: payment.from_user_id)
        unless other_user.blank?
          text << "You received #{payment.amount} from #{other_user.last.slack_username} on #{payment.created_at.strftime('%m-%d-%Y')} \n"
        end
      end
    end
    text
  end

  def self.paid_history(user_id)
    text = ""
    payments_from = Payment.where(from_user_id: user_id)

    if payments_from.blank?
      text << "You haven't sent any payments"
    else
      payments_from.each do |payment|
        other_user = User.select(:id, :slack_username).where(id: payment.to_user_id)
        unless other_user.blank?
          text << "You sent @#{other_user.last.slack_username} #{payment.amount} on #{payment.created_at.strftime('%m-%d-%Y')} \n"
        end
      end
    end
    text
  end

end
