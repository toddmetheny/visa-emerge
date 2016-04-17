class AddUsernameToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :to_username, :string
  end
end
