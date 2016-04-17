class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :description
      t.string :payment_to
      t.integer :amount_owed

      t.timestamps null: false
    end
  end
end
