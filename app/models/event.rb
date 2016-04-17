class Event < ActiveRecord::Base
  has_many :invoices
end
