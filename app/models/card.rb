# t.string   "card_number"
# t.string   "expiration"
# t.string   "csv"

class Card < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :card_number, :expiration, :csv
  
end
