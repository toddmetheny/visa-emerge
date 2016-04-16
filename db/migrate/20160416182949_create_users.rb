class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :slack_team, index: true, foreign_key: true
      t.string :slack_user_id
      t.string :slack_username

      t.timestamps null: false
    end
  end
end
