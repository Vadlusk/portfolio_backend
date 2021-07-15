# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_14_232532) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

# Could not dump table "accounts" because of following StandardError
#   Unknown type 'category_type' for column 'category'

  create_table "assets", force: :cascade do |t|
    t.string "remote_id"
    t.string "balance"
    t.string "currency"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_assets_on_account_id"
  end

  create_table "coin_gecko_coin_ids", force: :cascade do |t|
    t.string "coin_gecko_id"
    t.string "symbol"
    t.string "name"
  end

# Could not dump table "transactions" because of following StandardError
#   Unknown type 'transaction_type' for column 'transaction_type'

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "assets", "accounts"
  add_foreign_key "transactions", "accounts"
end
