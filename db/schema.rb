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

ActiveRecord::Schema.define(version: 20160509132110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bottles", force: :cascade do |t|
    t.string   "number",                               null: false
    t.string   "gas"
    t.string   "size"
    t.string   "name"
    t.string   "content"
    t.integer  "cert_price_cents",         default: 0, null: false
    t.integer  "cert_price_net_cents",     default: 0, null: false
    t.integer  "deposit_price_cents",      default: 0, null: false
    t.integer  "deposit_price_net_cents",  default: 0, null: false
    t.integer  "disposal_price_cents",     default: 0, null: false
    t.integer  "disposal_price_net_cents", default: 0, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "salut"
    t.string   "name",                            null: false
    t.string   "name2"
    t.boolean  "own_customer",    default: true
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.string   "phone"
    t.string   "email"
    t.boolean  "gets_invoice",    default: true
    t.string   "region"
    t.string   "kind"
    t.boolean  "price_in_net",    default: true
    t.boolean  "has_stock",       default: false
    t.date     "last_stock_date"
    t.text     "invoice_address"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "mobile"
    t.boolean  "archived",        default: false
  end

  create_table "deliveries", force: :cascade do |t|
    t.string   "number"
    t.string   "number_show"
    t.integer  "customer_id"
    t.date     "date"
    t.string   "driver"
    t.text     "description"
    t.string   "invoice_number"
    t.boolean  "on_account"
    t.integer  "discount_net_cents", default: 0, null: false
    t.integer  "discount_cents",     default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "deliveries", ["customer_id"], name: "index_deliveries_on_customer_id", using: :btree
  add_index "deliveries", ["date"], name: "index_deliveries_on_date", using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "prices", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "bottle_id"
    t.date     "valid_from"
    t.integer  "price_cents",    default: 0, null: false
    t.integer  "discount_cents", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "prices", ["bottle_id"], name: "index_prices_on_bottle_id", using: :btree
  add_index "prices", ["customer_id"], name: "index_prices_on_customer_id", using: :btree

  create_table "sellers", force: :cascade do |t|
    t.string   "short",      null: false
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.integer  "role"
    t.string   "username"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "deliveries", "customers"
  add_foreign_key "prices", "bottles"
  add_foreign_key "prices", "customers"
end
