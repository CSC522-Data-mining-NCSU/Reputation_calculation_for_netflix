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

ActiveRecord::Schema.define(version: 20151108010330) do

  create_table "review_records", force: :cascade do |t|
    t.integer "submission_id", limit: 4
    t.integer "reviewer_id",   limit: 4
    t.float   "score",         limit: 24
    t.float   "quiz_score",    limit: 24
  end

  create_table "reviewers", force: :cascade do |t|
    t.float "reputation", limit: 24
    t.float "leniency",   limit: 24
    t.float "variance",   limit: 24
    t.float "weight",     limit: 24
  end

  create_table "submissions", force: :cascade do |t|
    t.float "temp_score", limit: 24
  end

end
