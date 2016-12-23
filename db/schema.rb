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

ActiveRecord::Schema.define(version: 20161223223416) do

  create_table "ruby_gems", force: :cascade do |t|
    t.string   "url"
    t.string   "name"
    t.integer  "downloads"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "stars"
    t.float    "score"
    t.text     "description"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "github_username"
    t.string   "email"
    t.integer  "stars"
    t.integer  "followers"
    t.float    "score"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
