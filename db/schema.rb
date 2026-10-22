# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_21_122232) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "drivers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.string "guarantor_name"
    t.string "guarantor_phone"
    t.text "notes"
    t.boolean "active", default: true, null: false
    t.boolean "reminders_enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "phone"], name: "index_drivers_on_user_id_and_phone", unique: true
    t.index ["user_id"], name: "index_drivers_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "phone", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "plate_number", null: false
    t.string "vehicle_type", null: false
    t.string "nickname"
    t.bigint "rate_kobo", null: false
    t.string "rate_frequency", default: "daily", null: false
    t.integer "rest_days", default: [], null: false, array: true
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "plate_number"], name: "index_vehicles_on_user_id_and_plate_number", unique: true
    t.index ["user_id"], name: "index_vehicles_on_user_id"
    t.check_constraint "rate_frequency::text = ANY (ARRAY['daily'::character varying, 'weekly'::character varying]::text[])", name: "vehicles_rate_frequency_valid"
    t.check_constraint "rate_kobo > 0", name: "vehicles_rate_kobo_positive"
    t.check_constraint "rest_days <@ ARRAY[0, 1, 2, 3, 4, 5, 6]", name: "vehicles_rest_days_valid"
    t.check_constraint "vehicle_type::text = ANY (ARRAY['keke'::character varying, 'okada'::character varying, 'bus'::character varying, 'car'::character varying, 'truck'::character varying]::text[])", name: "vehicles_vehicle_type_valid"
  end

  add_foreign_key "drivers", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "vehicles", "users"
end
