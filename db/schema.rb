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

ActiveRecord::Schema.define(version: 20150804153349) do

  create_table "gifs", force: :cascade do |t|
    t.string   "title"
    t.string   "source_url"
    t.integer  "session_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "queue_status",               default: 0
    t.string   "status"
    t.string   "progress"
    t.string   "url"
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "video_length"
    t.integer  "external_validation_status", default: 0
    t.string   "temporary_download_link"
    t.string   "abort_reason"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
