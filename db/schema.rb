# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160417063333) do

  create_table "cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "card_number"
    t.string   "expiration"
    t.string   "csv"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "cards", ["user_id"], name: "index_cards_on_user_id"

  create_table "events", force: :cascade do |t|
    t.string   "description"
    t.string   "payment_to"
    t.integer  "amount_owed"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "invoices", force: :cascade do |t|
    t.string   "status"
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "invoices", ["event_id"], name: "index_invoices_on_event_id"
  add_index "invoices", ["user_id"], name: "index_invoices_on_user_id"

  create_table "payments", force: :cascade do |t|
    t.integer  "from_user_id"
    t.integer  "from_card_id"
    t.integer  "to_user_id"
    t.integer  "to_card_id"
    t.integer  "amount"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "to_username"
  end

  create_table "slack_teams", force: :cascade do |t|
    t.boolean  "ok"
    t.string   "access_token"
    t.string   "scope"
    t.string   "slack_user_id"
    t.string   "team_name"
    t.string   "team_id"
    t.string   "channel"
    t.string   "channel_id"
    t.string   "configuration_url"
    t.string   "url"
    t.string   "bot_user_id"
    t.string   "bot_access_token"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "slack_team_id"
    t.string   "slack_user_id"
    t.string   "slack_username"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "users", ["slack_team_id"], name: "index_users_on_slack_team_id"

end
