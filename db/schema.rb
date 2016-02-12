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

ActiveRecord::Schema.define(version: 20160208004202) do

  create_table "blocker_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "blocker_id"
    t.integer  "site_id"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "blocker_users", ["blocker_id"], name: "index_blocker_users_on_blocker_id"
  add_index "blocker_users", ["site_id"], name: "index_blocker_users_on_site_id"
  add_index "blocker_users", ["user_id"], name: "index_blocker_users_on_user_id"

  create_table "blockers", force: :cascade do |t|
    t.string   "title"
    t.text     "rule"
    t.integer  "count",      default: 0
    t.integer  "created_by"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "site_users", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.datetime "accessed_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "site_users", ["site_id"], name: "index_site_users_on_site_id"
  add_index "site_users", ["user_id"], name: "index_site_users_on_user_id"

  create_table "sites", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.string   "locale"
    t.integer  "count",      default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sites", ["url", "locale"], name: "index_sites_on_url_and_locale", unique: true

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "authentication_token"
    t.string   "username"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
