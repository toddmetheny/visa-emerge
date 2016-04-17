# t.string   "card_number"
# t.string   "expiration"
# t.string   "csv"

# SLACK_CLIENT_ID="3110874209.35282360436"
# SLACK_CLIENT_SECRET="69933a9e160d3c06da5f5276cedafe43"

class Card < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :card_number, :expiration, :csv
  validates_uniqueness_of :card_number
  
end
