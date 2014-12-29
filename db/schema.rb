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

ActiveRecord::Schema.define(version: 20141216110309) do

  create_table "balance_histories", force: true do |t|
    t.string   "user_id",         limit: 8,                          null: false
    t.integer  "user_balance_id"
    t.string   "history_type"
    t.decimal  "amount",                    precision: 16, scale: 3
    t.string   "reason",                                             null: false
    t.string   "operator_id",     limit: 8
    t.datetime "created_at"
  end

  add_index "balance_histories", ["user_balance_id"], name: "index_balance_histories_on_user_balance_id", using: :btree
  add_index "balance_histories", ["user_id"], name: "index_balance_histories_on_user_id", using: :btree

  create_table "beta_test_users", force: true do |t|
    t.string   "username",       limit: 80,  null: false
    t.string   "email",          limit: 80,  null: false
    t.string   "password",                   null: false
    t.string   "cell_phone_num", limit: 20,  null: false
    t.string   "qq",             limit: 20,  null: false
    t.string   "address",        limit: 200, null: false
    t.string   "zip_code",       limit: 20,  null: false
    t.string   "phone_type",     limit: 20,  null: false
    t.string   "os",             limit: 20,  null: false
    t.string   "hardware_uuid",  limit: 100, null: false
    t.string   "ID_card_pic",    limit: 100
    t.string   "ID_card_num",    limit: 30
    t.string   "real_name",      limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", force: true do |t|
    t.string   "name"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "faqs", force: true do |t|
    t.string   "live_show_id", limit: 8, null: false
    t.string   "question"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inbound_orders", force: true do |t|
    t.integer  "inbound_id",           null: false
    t.string   "order_id",   limit: 8, null: false
    t.datetime "created_at"
  end

  add_index "inbound_orders", ["inbound_id"], name: "index_inbound_orders_on_inbound_id", using: :btree
  add_index "inbound_orders", ["order_id"], name: "index_inbound_orders_on_order_id", using: :btree

  create_table "inbound_skus", force: true do |t|
    t.integer  "inbound_id"
    t.integer  "sku_id"
    t.integer  "quantity"
    t.integer  "inbounded_quantity", default: 0
    t.datetime "created_at"
  end

  create_table "inbounds", force: true do |t|
    t.integer  "channel_id"
    t.string   "channel_inbound_no"
    t.integer  "quantity"
    t.integer  "inbounded_quantity",           default: 0
    t.string   "remark"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "live_show_id",       limit: 8
  end

  create_table "live_show_users", force: true do |t|
    t.string   "user_id",      limit: 8,             null: false
    t.string   "live_show_id", limit: 8,             null: false
    t.integer  "status",                 default: 0
    t.integer  "role",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "live_show_users", ["live_show_id"], name: "index_live_show_users_on_live_show_id", using: :btree
  add_index "live_show_users", ["user_id"], name: "index_live_show_users_on_user_id", using: :btree

  create_table "live_shows", id: false, force: true do |t|
    t.string   "id",             limit: 8,                 null: false
    t.string   "user_id",        limit: 8,                 null: false
    t.integer  "messages_count",           default: 0
    t.integer  "products_count",           default: 0
    t.integer  "orders_count"
    t.string   "host_ids"
    t.string   "subject",                                  null: false
    t.string   "location"
    t.text     "description"
    t.string   "preview"
    t.string   "html_url"
    t.integer  "countdown"
    t.string   "exchange_rate"
    t.integer  "status",                   default: 0
    t.datetime "start_time",                               null: false
    t.datetime "close_time"
    t.boolean  "start",                    default: false
    t.boolean  "closed",                   default: false
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "live_shows", ["id"], name: "index_live_shows_on_id", unique: true, using: :btree

  create_table "lu_categories", force: true do |t|
    t.integer  "parent_id",                                                   default: 0,                     null: false
    t.string   "name",                   limit: 50,                                                           null: false
    t.string   "ename",                  limit: 100
    t.integer  "show_order",                                                  default: 0,                     null: false
    t.decimal  "force_insurance_amount",             precision: 20, scale: 4, default: 0.0
    t.string   "memo",                   limit: 50
    t.string   "unit",                   limit: 20
    t.string   "material",               limit: 50
    t.string   "state",                  limit: 50,                           default: "ACTIVE",              null: false
    t.datetime "created_at"
    t.datetime "deleted_at",                                                  default: '1970-01-01 00:00:00', null: false
  end

  add_index "lu_categories", ["deleted_at"], name: "index_lu_categories_on_deleted_at", using: :btree
  add_index "lu_categories", ["parent_id"], name: "index_lu_categories_on_parent_id", using: :btree
  add_index "lu_categories", ["show_order"], name: "index_lu_categories_on_show_order", using: :btree
  add_index "lu_categories", ["state"], name: "index_lu_categories_on_state", using: :btree

  create_table "lu_regions", force: true do |t|
    t.string  "name",       limit: 50, null: false
    t.integer "show_order"
    t.string  "pinyin",     limit: 50
  end

  add_index "lu_regions", ["show_order"], name: "index_lu_regions_on_show_order", using: :btree

  create_table "materials", id: false, force: true do |t|
    t.string   "id",            limit: 8, null: false
    t.string   "user_id",       limit: 8, null: false
    t.string   "live_show_id",  limit: 8, null: false
    t.string   "material_type",           null: false
    t.text     "meta"
    t.string   "resource"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "materials", ["id"], name: "index_materials_on_id", unique: true, using: :btree
  add_index "materials", ["live_show_id"], name: "index_materials_on_live_show_id", using: :btree
  add_index "materials", ["user_id"], name: "index_materials_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.string   "user_id",      limit: 8,                       null: false
    t.string   "live_show_id", limit: 8
    t.string   "to_user_id",   limit: 8
    t.string   "chat_type",              default: "groupchat", null: false
    t.text     "body",                                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["live_show_id"], name: "index_messages_on_live_show_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "order_items", force: true do |t|
    t.string   "order_id",     limit: 8, null: false
    t.string   "product_id",   limit: 8, null: false
    t.string   "sku_id",       limit: 8, null: false
    t.string   "live_show_id", limit: 8, null: false
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", id: false, force: true do |t|
    t.string   "id",              limit: 8,                                           null: false
    t.string   "order_no",        limit: 13
    t.string   "user_id",         limit: 8,                                           null: false
    t.string   "live_show_id",    limit: 8
    t.decimal  "original_amount",            precision: 16, scale: 3
    t.decimal  "amount",                     precision: 16, scale: 3
    t.integer  "status",                                              default: 0
    t.integer  "recipient_id",                                                        null: false
    t.string   "code",                                                default: "000"
    t.string   "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["id"], name: "index_orders_on_id", unique: true, using: :btree
  add_index "orders", ["status"], name: "index_orders_on_status", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "outbound_skus", force: true do |t|
    t.integer  "outbound_id"
    t.integer  "sku_id"
    t.integer  "quantity"
    t.datetime "created_at"
  end

  create_table "outbounds", force: true do |t|
    t.string   "outbound_no",                                    null: false
    t.string   "channel_outbound_no"
    t.integer  "inbound_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_id",            limit: 8
    t.float    "tax",                 limit: 24, default: 0.0
    t.boolean  "has_tax",                        default: false
  end

  create_table "product_materials", force: true do |t|
    t.string   "product_id",  limit: 8, null: false
    t.string   "material_id", limit: 8, null: false
    t.datetime "created_at"
  end

  create_table "product_specifications", force: true do |t|
    t.string   "product_id", limit: 8,              null: false
    t.integer  "parent_id",            default: 0
    t.string   "name",                 default: "", null: false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_specifications", ["parent_id"], name: "index_product_specifications_on_parent_id", using: :btree
  add_index "product_specifications", ["product_id"], name: "index_product_specifications_on_product_id", using: :btree

  create_table "products", id: false, force: true do |t|
    t.string   "id",                limit: 8,                                              null: false
    t.string   "live_show_id",      limit: 8,                                              null: false
    t.string   "author_id",         limit: 8,                                              null: false
    t.string   "cover_id",          limit: 8,                                              null: false
    t.string   "name_en",                                                                  null: false
    t.string   "name_cn",                                                                  null: false
    t.decimal  "price",                        precision: 16, scale: 3
    t.string   "currency",                                              default: "Dollar"
    t.decimal  "clearing_price",               precision: 16, scale: 3
    t.string   "clearing_currency",                                     default: "RMB"
    t.integer  "status",                                                default: 0
    t.text     "description",                                                              null: false
    t.float    "tax_rate",          limit: 24
    t.string   "brand_cn"
    t.string   "brand_en"
    t.float    "weight",            limit: 24
    t.string   "weight_unit"
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["id"], name: "index_products_on_id", unique: true, using: :btree
  add_index "products", ["live_show_id", "status"], name: "index_products_on_live_show_id_and_status", using: :btree
  add_index "products", ["live_show_id"], name: "index_products_on_live_show_id", using: :btree

  create_table "recipients", force: true do |t|
    t.string   "user_id",             limit: 8, null: false
    t.string   "zip_code"
    t.string   "name",                          null: false
    t.integer  "region_id"
    t.string   "address",                       null: false
    t.string   "tel",                           null: false
    t.string   "email",                         null: false
    t.string   "id_card_no"
    t.string   "id_card_pic_obverse"
    t.string   "id_card_pic_back"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skus", force: true do |t|
    t.string   "sku_id"
    t.string   "product_id", limit: 8,  null: false
    t.text     "prop"
    t.float    "weight",     limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skus", ["product_id"], name: "index_skus_on_product_id", using: :btree
  add_index "skus", ["sku_id"], name: "index_skus_on_sku_id", unique: true, using: :btree

  create_table "tokens", force: true do |t|
    t.string   "type",                    null: false
    t.string   "user_id",    default: ""
    t.string   "body",                    null: false
    t.string   "phone"
    t.string   "email"
    t.integer  "status",     default: 0
    t.datetime "created_at"
    t.datetime "deleted_at"
  end

  add_index "tokens", ["id"], name: "index_tokens_on_id", unique: true, using: :btree
  add_index "tokens", ["user_id"], name: "index_tokens_on_user_id", using: :btree

  create_table "user_balances", id: false, force: true do |t|
    t.string   "user_id",    limit: 8,                                        null: false
    t.decimal  "balance",              precision: 16, scale: 3, default: 0.0
    t.integer  "status",                                        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_devices", force: true do |t|
    t.string   "user_id",           limit: 8, null: false
    t.string   "jpush_register_id"
    t.string   "device_name"
    t.string   "device_token"
    t.string   "os"
    t.string   "os_version"
    t.string   "client_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_goods_in_carts", force: true do |t|
    t.string   "user_id",      limit: 8, null: false
    t.string   "live_show_id", limit: 8, null: false
    t.integer  "sku_id"
    t.string   "product_id",   limit: 8, null: false
    t.integer  "quantity"
    t.datetime "created_at"
  end

  create_table "user_tokens", force: true do |t|
    t.string   "user_id",      limit: 8, null: false
    t.string   "device_name"
    t.string   "device_token"
    t.string   "os"
    t.string   "os_version"
    t.string   "token",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: false, force: true do |t|
    t.string   "id",                     limit: 8,                  null: false
    t.string   "name",                   limit: 80,                 null: false
    t.string   "username",               limit: 80,                 null: false
    t.string   "email"
    t.string   "password_digest",                                   null: false
    t.string   "avatar"
    t.string   "phone"
    t.string   "private_token"
    t.datetime "last_sign_in_at"
    t.string   "last_sign_in_ip"
    t.string   "last_sign_in_device"
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "current_sign_in_device"
    t.integer  "sign_in_count",                     default: 0
    t.integer  "status",                            default: 0
    t.boolean  "confirmed",                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["id"], name: "index_users_on_id", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
