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

ActiveRecord::Schema[7.1].define(version: 2025_04_15_080624) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "team_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "batting_style"
    t.string "bowling_style"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_players_on_team_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "series", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tournament_id", null: false
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.string "series_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_series_on_tournament_id"
    t.index ["user_id"], name: "index_series_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "logo_url"
    t.string "home_ground"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "tournament_teams", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_tournament_teams_on_team_id"
    t.index ["tournament_id", "team_id"], name: "index_tournament_teams_on_tournament_id_and_team_id", unique: true
    t.index ["tournament_id"], name: "index_tournament_teams_on_tournament_id"
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
    t.string "username"
    t.string "jti"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

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
  add_foreign_key "players", "teams"
  add_foreign_key "players", "users"
  add_foreign_key "series", "tournaments"
  add_foreign_key "series", "users"
  add_foreign_key "teams", "users"
  add_foreign_key "tournament_teams", "teams"
  add_foreign_key "tournament_teams", "tournaments"
  add_foreign_key "tournaments", "users"
end
