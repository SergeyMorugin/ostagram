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

ActiveRecord::Schema.define(version: 20151222172729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "name",                                null: false
    t.string   "avatar",                              null: false
    t.datetime "lastprocess"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "role_id",                default: 0
  end

  add_index "clients", ["confirmation_token"], name: "index_clients_on_confirmation_token", unique: true, using: :btree
  add_index "clients", ["email"], name: "index_clients_on_email", unique: true, using: :btree
  add_index "clients", ["reset_password_token"], name: "index_clients_on_reset_password_token", unique: true, using: :btree
  add_index "clients", ["unlock_token"], name: "index_clients_on_unlock_token", unique: true, using: :btree

  create_table "contents", force: :cascade do |t|
    t.string   "image",                  null: false
    t.integer  "status",     default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "queue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pimages", force: :cascade do |t|
    t.integer  "queue_image_id"
    t.integer  "iterate"
    t.string   "imageurl"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "queue_images", force: :cascade do |t|
    t.integer  "client_id",                 null: false
    t.string   "init_str",    default: ""
    t.integer  "status",      default: 0
    t.string   "result",      default: ""
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.time     "ptime"
    t.datetime "stime"
    t.datetime "ftime"
    t.integer  "style_id",    default: 0,   null: false
    t.integer  "content_id",  default: 0,   null: false
    t.integer  "end_status",  default: 11,  null: false
    t.integer  "likes_count", default: 0
    t.float    "progress",    default: 0.0
  end

  create_table "styles", force: :cascade do |t|
    t.string   "image",                   null: false
    t.string   "init"
    t.integer  "status",      default: 0, null: false
    t.integer  "use_counter", default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
