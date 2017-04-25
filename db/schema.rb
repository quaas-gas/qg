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

ActiveRecord::Schema.define(version: 20170423203029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string   "salut"
    t.string   "name",                               null: false
    t.string   "name2"
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.boolean  "gets_invoice",       default: true
    t.string   "region"
    t.string   "kind"
    t.boolean  "tax",                default: true
    t.boolean  "has_stock",          default: false
    t.date     "last_stock_date"
    t.text     "invoice_address"
    t.boolean  "archived",           default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "notes"
    t.string   "category"
    t.date     "initial_stock_date"
  end

  add_index "customers", ["category"], name: "index_customers_on_category", using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.string   "number"
    t.string   "number_show"
    t.integer  "customer_id"
    t.integer  "seller_id"
    t.date     "date"
    t.string   "driver"
    t.text     "description"
    t.string   "invoice_number"
    t.boolean  "tax",            default: true
    t.boolean  "on_account"
    t.jsonb    "others"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "invoice_id"
  end

  add_index "deliveries", ["customer_id"], name: "index_deliveries_on_customer_id", using: :btree
  add_index "deliveries", ["date"], name: "index_deliveries_on_date", using: :btree
  add_index "deliveries", ["invoice_id"], name: "index_deliveries_on_invoice_id", using: :btree
  add_index "deliveries", ["seller_id"], name: "index_deliveries_on_seller_id", using: :btree

  create_table "delivery_items", force: :cascade do |t|
    t.integer  "delivery_id"
    t.integer  "product_id"
    t.string   "name"
    t.integer  "count"
    t.integer  "count_back"
    t.integer  "unit_price_cents",     default: 0,        null: false
    t.string   "unit_price_currency",  default: "EU4NET", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.jsonb    "others"
    t.string   "product_category",     default: ""
    t.string   "product_group",        default: ""
    t.integer  "total_price_cents",    default: 0,        null: false
    t.string   "total_price_currency", default: "EU4NET", null: false
    t.integer  "total_content_in_g"
    t.string   "product_number"
    t.boolean  "has_content"
  end

  add_index "delivery_items", ["delivery_id"], name: "index_delivery_items_on_delivery_id", using: :btree
  add_index "delivery_items", ["has_content"], name: "index_delivery_items_on_has_content", using: :btree
  add_index "delivery_items", ["product_id"], name: "index_delivery_items_on_product_id", using: :btree
  add_index "delivery_items", ["product_number"], name: "index_delivery_items_on_product_number", using: :btree

  create_table "invoice_items", force: :cascade do |t|
    t.integer  "invoice_id"
    t.integer  "position"
    t.integer  "count"
    t.string   "name",                                   null: false
    t.integer  "unit_price_cents",    default: 0,        null: false
    t.string   "unit_price_currency", default: "EU4NET", null: false
    t.jsonb    "others"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "product_id"
  end

  add_index "invoice_items", ["invoice_id"], name: "index_invoice_items_on_invoice_id", using: :btree
  add_index "invoice_items", ["product_id"], name: "index_invoice_items_on_product_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "number",                       null: false
    t.date     "date"
    t.boolean  "tax"
    t.text     "pre_message"
    t.text     "post_message"
    t.text     "address"
    t.boolean  "printed",      default: false
    t.jsonb    "others"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "invoices", ["customer_id"], name: "index_invoices_on_customer_id", using: :btree
  add_index "invoices", ["date"], name: "index_invoices_on_date", using: :btree

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
    t.integer  "product_id"
    t.date     "valid_from"
    t.integer  "price_cents",           default: 0,        null: false
    t.string   "price_currency",        default: "EU4NET", null: false
    t.integer  "discount_cents",        default: 0,        null: false
    t.string   "discount_currency",     default: "EU4NET", null: false
    t.jsonb    "others"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "active",                default: true
    t.boolean  "in_stock",              default: true
    t.integer  "initial_stock_balance", default: 0
  end

  add_index "prices", ["customer_id"], name: "index_prices_on_customer_id", using: :btree
  add_index "prices", ["product_id"], name: "index_prices_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "number"
    t.string   "name"
    t.string   "size"
    t.float    "content",        default: 0.0
    t.integer  "price_cents",    default: 0,        null: false
    t.string   "price_currency", default: "EU4NET", null: false
    t.jsonb    "others"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "category"
    t.boolean  "in_stock",       default: false
    t.string   "unit"
    t.string   "group"
  end

  add_index "products", ["category"], name: "index_products_on_category", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "product_categories"
    t.jsonb    "content_product_categories"
    t.jsonb    "products"
    t.boolean  "in_menu"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "sellers", force: :cascade do |t|
    t.string   "short",      null: false
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "statistics", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "time_range", default: {}
    t.jsonb    "grouping",   default: {}
    t.jsonb    "filter",     default: {}
    t.string   "sums_of"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
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
  add_foreign_key "delivery_items", "deliveries", on_delete: :cascade
  add_foreign_key "invoice_items", "invoices", on_delete: :cascade
  add_foreign_key "invoices", "customers"
  add_foreign_key "prices", "customers"
  add_foreign_key "prices", "products"
end
