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

ActiveRecord::Schema[7.1].define(version: 2025_04_25_122143) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "batting_scorecards", force: :cascade do |t|
    t.bigint "inning_id", null: false
    t.bigint "player_id", null: false
    t.integer "runs", default: 0
    t.integer "balls", default: 0
    t.integer "fours", default: 0
    t.integer "sixes", default: 0
    t.string "how_out"
    t.bigint "bowler_id"
    t.bigint "fielder_id"
    t.integer "batting_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bowler_id"], name: "index_batting_scorecards_on_bowler_id"
    t.index ["fielder_id"], name: "index_batting_scorecards_on_fielder_id"
    t.index ["inning_id"], name: "index_batting_scorecards_on_inning_id"
    t.index ["player_id"], name: "index_batting_scorecards_on_player_id"
  end

  create_table "bowling_scorecards", force: :cascade do |t|
    t.bigint "inning_id", null: false
    t.bigint "player_id", null: false
    t.decimal "overs"
    t.integer "maidens"
    t.integer "runs"
    t.integer "wickets"
    t.integer "no_balls"
    t.integer "wides"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inning_id"], name: "index_bowling_scorecards_on_inning_id"
    t.index ["player_id"], name: "index_bowling_scorecards_on_player_id"
  end

  create_table "innings", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.integer "number"
    t.bigint "batting_team_id"
    t.bigint "bowling_team_id"
    t.integer "total_runs", default: 0
    t.integer "total_wickets", default: 0
    t.decimal "total_overs"
    t.integer "extras", default: 0
    t.boolean "declared", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batting_team_id"], name: "index_innings_on_batting_team_id"
    t.index ["bowling_team_id"], name: "index_innings_on_bowling_team_id"
    t.index ["match_id"], name: "index_innings_on_match_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "series_id"
    t.bigint "tournament_id"
    t.bigint "team1_id"
    t.bigint "team2_id"
    t.datetime "match_date"
    t.string "venue"
    t.string "match_type"
    t.string "status"
    t.bigint "toss_winner_id"
    t.string "toss_decision"
    t.string "result"
    t.bigint "winning_team_id"
    t.string "winning_margin"
    t.bigint "man_of_the_match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["man_of_the_match_id"], name: "index_matches_on_man_of_the_match_id"
    t.index ["series_id"], name: "index_matches_on_series_id"
    t.index ["team1_id"], name: "index_matches_on_team1_id"
    t.index ["team2_id"], name: "index_matches_on_team2_id"
    t.index ["toss_winner_id"], name: "index_matches_on_toss_winner_id"
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
    t.index ["user_id"], name: "index_matches_on_user_id"
    t.index ["winning_team_id"], name: "index_matches_on_winning_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "batting_style"
    t.string "bowling_style"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "series", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.string "series_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_series_on_user_id"
  end

  create_table "team_tournament_players", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "team_id", null: false
    t.bigint "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "team_id", "tournament_id"], name: "index_unique_team_tournament_players", unique: true
    t.index ["player_id"], name: "index_team_tournament_players_on_player_id"
    t.index ["team_id"], name: "index_team_tournament_players_on_team_id"
    t.index ["tournament_id"], name: "index_team_tournament_players_on_tournament_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "logo_url"
    t.string "home_ground"
    t.bigint "captain_id"
    t.bigint "vice_captain_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["captain_id"], name: "index_teams_on_captain_id"
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["user_id"], name: "index_teams_on_user_id"
    t.index ["vice_captain_id"], name: "index_teams_on_vice_captain_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.integer "tournament_type"
    t.integer "total_teams"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tournaments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "date_of_birth"
    t.string "address"
    t.string "jti"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["last_name"], name: "index_users_on_last_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "batting_scorecards", "innings"
  add_foreign_key "batting_scorecards", "players"
  add_foreign_key "batting_scorecards", "players", column: "bowler_id"
  add_foreign_key "batting_scorecards", "players", column: "fielder_id"
  add_foreign_key "bowling_scorecards", "innings"
  add_foreign_key "bowling_scorecards", "players"
  add_foreign_key "innings", "matches"
  add_foreign_key "innings", "teams", column: "batting_team_id"
  add_foreign_key "innings", "teams", column: "bowling_team_id"
  add_foreign_key "matches", "players", column: "man_of_the_match_id"
  add_foreign_key "matches", "series"
  add_foreign_key "matches", "teams", column: "team1_id"
  add_foreign_key "matches", "teams", column: "team2_id"
  add_foreign_key "matches", "teams", column: "toss_winner_id"
  add_foreign_key "matches", "teams", column: "winning_team_id"
  add_foreign_key "matches", "tournaments"
  add_foreign_key "matches", "users"
  add_foreign_key "players", "users"
  add_foreign_key "series", "users"
  add_foreign_key "team_tournament_players", "players"
  add_foreign_key "team_tournament_players", "teams"
  add_foreign_key "team_tournament_players", "tournaments"
  add_foreign_key "teams", "players", column: "captain_id"
  add_foreign_key "teams", "players", column: "vice_captain_id"
  add_foreign_key "teams", "users"
  add_foreign_key "tournaments", "users"
end
