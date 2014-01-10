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

ActiveRecord::Schema.define(version: 20140110123349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contests", force: true do |t|
    t.string   "title"
    t.string   "sport"
    t.string   "contest_type"
    t.decimal  "prize"
    t.decimal  "entry_fee"
    t.datetime "contest_start"
    t.integer  "lineups_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contests", ["contest_start"], name: "index_contests_on_contest_start", using: :btree

  create_table "entries", force: true do |t|
    t.integer  "user_id"
    t.integer  "lineup_id"
    t.integer  "player_id"
    t.string   "sport"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sport_position_id"
  end

  add_index "entries", ["lineup_id"], name: "index_entries_on_lineup_id", using: :btree
  add_index "entries", ["player_id"], name: "index_entries_on_player_id", using: :btree
  add_index "entries", ["sport_position_id"], name: "index_entries_on_sport_position_id", using: :btree
  add_index "entries", ["user_id"], name: "index_entries_on_user_id", using: :btree

  create_table "lineup_spot_protos", force: true do |t|
    t.string   "sport"
    t.string   "sport_position_name"
    t.integer  "spot"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lineup_spots", force: true do |t|
    t.integer  "sport_position_id"
    t.integer  "lineup_id"
    t.integer  "player_id"
    t.integer  "spot"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lineup_spots", ["lineup_id"], name: "index_lineup_spots_on_lineup_id", using: :btree
  add_index "lineup_spots", ["player_id"], name: "index_lineup_spots_on_player_id", using: :btree
  add_index "lineup_spots", ["sport_position_id"], name: "index_lineup_spots_on_sport_position_id", using: :btree

  create_table "lineups", force: true do |t|
    t.integer  "user_id"
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lineups", ["contest_id"], name: "index_lineups_on_contest_id", using: :btree
  add_index "lineups", ["user_id"], name: "index_lineups_on_user_id", using: :btree

  create_table "player_stats", force: true do |t|
    t.integer  "player_id"
    t.string   "index_name"
    t.string   "index_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "player_stats", ["player_id"], name: "index_player_stats_on_player_id", using: :btree

  create_table "players", force: true do |t|
    t.string   "name"
    t.string   "team"
    t.integer  "age"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sport_position_id"
    t.integer  "salary"
  end

  create_table "projection_game_playeds", force: true do |t|
    t.integer  "player_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projection_game_playeds", ["game_id"], name: "index_projection_game_playeds_on_game_id", using: :btree
  add_index "projection_game_playeds", ["player_id"], name: "index_projection_game_playeds_on_player_id", using: :btree

  create_table "projection_games", force: true do |t|
    t.datetime "gamedate"
    t.boolean  "is_home"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "home_team_id"
    t.integer  "opponent_team_id"
  end

  add_index "projection_games", ["home_team_id"], name: "index_projection_games_on_home_team_id", using: :btree
  add_index "projection_games", ["opponent_team_id"], name: "index_projection_games_on_opponent_team_id", using: :btree

  create_table "projection_players", force: true do |t|
    t.string   "ext_player_id"
    t.string   "player_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "fp"
    t.integer  "team_id"
  end

  add_index "projection_players", ["team_id"], name: "index_projection_players_on_team_id", using: :btree

  create_table "projection_stats", force: true do |t|
    t.string   "stat_name"
    t.decimal  "stat_value"
    t.integer  "player_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projection_stats", ["game_id"], name: "index_projection_stats_on_game_id", using: :btree
  add_index "projection_stats", ["player_id"], name: "index_projection_stats_on_player_id", using: :btree

  create_table "projection_teams", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sport_positions", force: true do |t|
    t.string   "name"
    t.string   "sport"
    t.integer  "display_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",          default: true
  end

  add_index "sport_positions", ["name", "sport"], name: "index_sport_positions_on_name_and_sport", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "waiting_lists", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invited_by_token"
    t.string   "invitation_token"
    t.integer  "status",           default: 1
    t.integer  "user_id"
  end

  add_index "waiting_lists", ["invitation_token"], name: "index_waiting_lists_on_invitation_token", using: :btree
  add_index "waiting_lists", ["invited_by_token"], name: "index_waiting_lists_on_invited_by_token", using: :btree
  add_index "waiting_lists", ["status"], name: "index_waiting_lists_on_status", using: :btree

end
