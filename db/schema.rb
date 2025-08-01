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

ActiveRecord::Schema[8.0].define(version: 2025_08_01_223130) do
  create_table "auctions", force: :cascade do |t|
    t.integer "rfq_id", null: false
    t.string "status"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rfq_id"], name: "index_auctions_on_rfq_id"
  end

  create_table "bids", force: :cascade do |t|
    t.integer "auction_id", null: false
    t.integer "user_id", null: false
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_bids_on_auction_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.decimal "price"
    t.text "notes"
    t.integer "rfq_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rfq_id"], name: "index_quotes_on_rfq_id"
    t.index ["user_id"], name: "index_quotes_on_user_id"
  end

  create_table "rfqs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "status"
    t.datetime "deadline"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_rfqs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "role", default: "buyer", null: false
    t.string "company_name"
    t.string "phone"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "auctions", "rfqs"
  add_foreign_key "bids", "auctions"
  add_foreign_key "bids", "users"
  add_foreign_key "quotes", "rfqs"
  add_foreign_key "quotes", "users"
  add_foreign_key "rfqs", "users"
end
