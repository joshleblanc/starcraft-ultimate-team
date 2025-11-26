# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_26_001600) do
  create_table "cards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "early_game", default: 0, null: false
    t.string "image_url"
    t.integer "late_game", default: 0, null: false
    t.integer "macro", default: 50, null: false
    t.integer "micro", default: 50, null: false
    t.integer "mid_game", default: 0, null: false
    t.string "name", null: false
    t.integer "overall_rating", default: 50, null: false
    t.string "player_role", default: "player"
    t.integer "poise", default: 50, null: false
    t.string "race", null: false
    t.string "rarity", default: "common", null: false
    t.integer "speed", default: 50, null: false
    t.integer "starsense", default: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["overall_rating"], name: "index_cards_on_overall_rating"
    t.index ["race"], name: "index_cards_on_race"
    t.index ["rarity"], name: "index_cards_on_rarity"
  end

  create_table "games", force: :cascade do |t|
    t.integer "away_player_id", null: false
    t.datetime "created_at", null: false
    t.string "deciding_phase"
    t.string "early_game_result"
    t.integer "game_number", null: false
    t.integer "home_player_id", null: false
    t.string "late_game_result"
    t.integer "match_id", null: false
    t.string "mid_game_result"
    t.json "simulation_log"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "winner_player_id"
    t.integer "winner_team_id"
    t.index ["away_player_id"], name: "index_games_on_away_player_id"
    t.index ["home_player_id"], name: "index_games_on_home_player_id"
    t.index ["match_id", "game_number"], name: "index_games_on_match_id_and_game_number", unique: true
    t.index ["match_id"], name: "index_games_on_match_id"
    t.index ["winner_player_id"], name: "index_games_on_winner_player_id"
    t.index ["winner_team_id"], name: "index_games_on_winner_team_id"
  end

  create_table "league_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_losses", default: 0
    t.integer "game_wins", default: 0
    t.integer "league_id", null: false
    t.integer "match_losses", default: 0
    t.integer "match_wins", default: 0
    t.integer "points", default: 0
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id", "points"], name: "index_league_memberships_on_league_id_and_points"
    t.index ["league_id", "team_id"], name: "index_league_memberships_on_league_id_and_team_id", unique: true
    t.index ["league_id"], name: "index_league_memberships_on_league_id"
    t.index ["team_id"], name: "index_league_memberships_on_team_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_round", default: 0
    t.datetime "ended_at"
    t.integer "max_teams", default: 8, null: false
    t.string "name", null: false
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.integer "total_rounds", default: 7
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_leagues_on_status"
  end

  create_table "lineup_slots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lineup_id", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.integer "user_card_id", null: false
    t.index ["lineup_id", "position"], name: "index_lineup_slots_on_lineup_id_and_position", unique: true
    t.index ["lineup_id", "user_card_id"], name: "index_lineup_slots_on_lineup_id_and_user_card_id", unique: true
    t.index ["lineup_id"], name: "index_lineup_slots_on_lineup_id"
    t.index ["user_card_id"], name: "index_lineup_slots_on_user_card_id"
  end

  create_table "lineups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "match_id", null: false
    t.boolean "submitted", default: false
    t.integer "team_id", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id", "team_id"], name: "index_lineups_on_match_id_and_team_id", unique: true
    t.index ["match_id"], name: "index_lineups_on_match_id"
    t.index ["team_id"], name: "index_lineups_on_team_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "away_score", default: 0
    t.integer "away_team_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "home_score", default: 0
    t.integer "home_team_id", null: false
    t.integer "league_id", null: false
    t.integer "round", null: false
    t.datetime "scheduled_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "winner_team_id"
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["league_id", "round"], name: "index_matches_on_league_id_and_round"
    t.index ["league_id"], name: "index_matches_on_league_id"
    t.index ["status"], name: "index_matches_on_status"
    t.index ["winner_team_id"], name: "index_matches_on_winner_team_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.json "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "params"
    t.datetime "read_at"
    t.integer "recipient_id", null: false
    t.string "recipient_type", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id", "read_at"], name: "index_notifications_on_recipient_and_read"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "pack_openings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "opened_at", null: false
    t.integer "pack_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["pack_id"], name: "index_pack_openings_on_pack_id"
    t.index ["user_id", "opened_at"], name: "index_pack_openings_on_user_id_and_opened_at"
    t.index ["user_id"], name: "index_pack_openings_on_user_id"
  end

  create_table "packs", force: :cascade do |t|
    t.integer "card_count", default: 5, null: false
    t.integer "common_weight", default: 70
    t.integer "cost", default: 100, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "epic_weight", default: 8
    t.integer "legendary_weight", default: 2
    t.string "name", null: false
    t.string "pack_type", default: "standard", null: false
    t.integer "rare_weight", default: 20
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "losses", default: 0
    t.string "name", null: false
    t.integer "rating", default: 1000
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "wins", default: 0
    t.index ["rating"], name: "index_teams_on_rating"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "user_cards", force: :cascade do |t|
    t.integer "card_id", null: false
    t.datetime "created_at", null: false
    t.boolean "is_starter", default: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["card_id"], name: "index_user_cards_on_card_id"
    t.index ["user_id", "is_starter"], name: "index_user_cards_on_user_id_and_is_starter"
    t.index ["user_id"], name: "index_user_cards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "credits", default: 1000, null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "games", "matches"
  add_foreign_key "games", "teams", column: "winner_team_id"
  add_foreign_key "games", "user_cards", column: "away_player_id"
  add_foreign_key "games", "user_cards", column: "home_player_id"
  add_foreign_key "games", "user_cards", column: "winner_player_id"
  add_foreign_key "league_memberships", "leagues"
  add_foreign_key "league_memberships", "teams"
  add_foreign_key "lineup_slots", "lineups"
  add_foreign_key "lineup_slots", "user_cards"
  add_foreign_key "lineups", "matches"
  add_foreign_key "lineups", "teams"
  add_foreign_key "matches", "leagues"
  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "matches", "teams", column: "winner_team_id"
  add_foreign_key "pack_openings", "packs"
  add_foreign_key "pack_openings", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "teams", "users"
  add_foreign_key "user_cards", "cards"
  add_foreign_key "user_cards", "users"
end
