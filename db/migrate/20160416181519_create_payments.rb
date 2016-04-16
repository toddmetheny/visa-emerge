class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :from_user_id
      t.integer :from_card_id
      t.integer :to_user_id
      t.integer :to_card_id
      t.integer :amount
      t.string :status

      t.timestamps null: false
    end
  end
end
