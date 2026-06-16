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

ActiveRecord::Schema[7.2].define(version: 2026_06_16_000000) do
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

  create_table "bracket_slots", force: :cascade do |t|
    t.string "code", null: false
    t.string "source_type", null: false
    t.string "group_letter"
    t.integer "position"
    t.bigint "source_match_id"
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_bracket_slots_on_code", unique: true
    t.index ["team_id"], name: "index_bracket_slots_on_team_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "created_at"], name: "index_comments_on_post_id_and_created_at"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "letter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["letter"], name: "index_groups_on_letter", unique: true
  end

  create_table "knockout_matches", force: :cascade do |t|
    t.integer "number", null: false
    t.string "round", null: false
    t.integer "bracket_position", null: false
    t.bigint "home_slot_id"
    t.bigint "away_slot_id"
    t.bigint "winner_slot_id"
    t.bigint "home_team_id"
    t.bigint "away_team_id"
    t.bigint "winner_team_id"
    t.datetime "kickoff_at"
    t.string "venue"
    t.integer "home_score"
    t.integer "away_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_slot_id"], name: "index_knockout_matches_on_away_slot_id"
    t.index ["away_team_id"], name: "index_knockout_matches_on_away_team_id"
    t.index ["home_slot_id"], name: "index_knockout_matches_on_home_slot_id"
    t.index ["home_team_id"], name: "index_knockout_matches_on_home_team_id"
    t.index ["number"], name: "index_knockout_matches_on_number", unique: true
    t.index ["round", "bracket_position"], name: "index_knockout_matches_on_round_and_bracket_position", unique: true
    t.index ["winner_slot_id"], name: "index_knockout_matches_on_winner_slot_id"
    t.index ["winner_team_id"], name: "index_knockout_matches_on_winner_team_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "number", null: false
    t.bigint "group_id"
    t.bigint "home_team_id"
    t.bigint "away_team_id"
    t.datetime "kickoff_at", null: false
    t.string "venue"
    t.integer "home_score"
    t.integer "away_score"
    t.string "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["group_id"], name: "index_matches_on_group_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["number"], name: "index_matches_on_number", unique: true
  end

  create_table "picks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "match_id"
    t.bigint "knockout_match_id"
    t.bigint "bracket_slot_id"
    t.bigint "team_id"
    t.string "group_result"
    t.integer "points_awarded", default: 0, null: false
    t.boolean "correct", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bracket_slot_id"], name: "index_picks_on_bracket_slot_id"
    t.index ["knockout_match_id"], name: "index_picks_on_knockout_match_id"
    t.index ["match_id"], name: "index_picks_on_match_id"
    t.index ["team_id"], name: "index_picks_on_team_id"
    t.index ["user_id", "knockout_match_id"], name: "index_picks_on_user_id_and_knockout_match_id", unique: true, where: "(knockout_match_id IS NOT NULL)"
    t.index ["user_id", "match_id"], name: "index_picks_on_user_id_and_match_id", unique: true, where: "(match_id IS NOT NULL)"
    t.index ["user_id"], name: "index_picks_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "approved_at"
    t.bigint "approved_by_id"
    t.string "post_type", default: "media", null: false
    t.string "link_url"
    t.string "og_title"
    t.text "og_description"
    t.string "og_image_url"
    t.string "og_site_name"
    t.index ["approved_at"], name: "index_posts_on_approved_at"
    t.index ["approved_by_id"], name: "index_posts_on_approved_by_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "site_settings", force: :cascade do |t|
    t.boolean "bracket_visible", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "flag_emoji"
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fifa_ranking"
    t.index ["code"], name: "index_teams_on_code", unique: true
    t.index ["group_id"], name: "index_teams_on_group_id"
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "display_name", null: false
    t.boolean "admin", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "paid", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bracket_slots", "teams"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "knockout_matches", "bracket_slots", column: "away_slot_id"
  add_foreign_key "knockout_matches", "bracket_slots", column: "home_slot_id"
  add_foreign_key "knockout_matches", "bracket_slots", column: "winner_slot_id"
  add_foreign_key "knockout_matches", "teams", column: "away_team_id"
  add_foreign_key "knockout_matches", "teams", column: "home_team_id"
  add_foreign_key "knockout_matches", "teams", column: "winner_team_id"
  add_foreign_key "matches", "groups"
  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "picks", "bracket_slots"
  add_foreign_key "picks", "knockout_matches"
  add_foreign_key "picks", "matches"
  add_foreign_key "picks", "teams"
  add_foreign_key "picks", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "teams", "groups"
end
