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

ActiveRecord::Schema.define(version: 20170119223031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "commits", force: :cascade do |t|
    t.string   "message"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "github_identifier"
    t.integer  "repository_id"
    t.datetime "github_created_at"
    t.index ["github_identifier"], name: "index_commits_on_github_identifier", using: :btree
  end

  create_table "issue_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "issue_id"
    t.text     "body"
    t.datetime "github_created_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["github_created_at"], name: "index_issue_comments_on_github_created_at", using: :btree
  end

  create_table "issues", force: :cascade do |t|
    t.integer  "repository_id"
    t.string   "name"
    t.string   "creator"
    t.string   "url"
    t.string   "open_date"
    t.integer  "issue_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "repositories", force: :cascade do |t|
    t.string   "name"
    t.integer  "github_id"
    t.string   "url"
    t.string   "language"
    t.integer  "stars"
    t.integer  "forks"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "readme_content"
    t.integer  "watchers"
    t.integer  "score"
    t.integer  "open_issues"
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
    t.index ["github_username"], name: "index_users_on_github_username", using: :btree
  end

end
