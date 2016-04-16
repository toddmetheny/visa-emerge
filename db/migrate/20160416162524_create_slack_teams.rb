class CreateSlackTeams < ActiveRecord::Migration
  def change
    create_table :slack_teams do |t|
      t.boolean :ok
      t.string :access_token
      t.string :scope
      t.string :slack_user_id
      t.string :team_name
      t.string :team_id
      t.string :channel
      t.string :channel_id
      t.string :configuration_url
      t.string :url
      t.string :bot_user_id
      t.string :bot_access_token

      t.timestamps null: false
    end
  end
end
