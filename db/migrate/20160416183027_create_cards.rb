class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :user, index: true, foreign_key: true
      t.string :card_number
      t.string :expiration
      t.string :csv

      t.timestamps null: false
    end
  end
end
