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

ActiveRecord::Schema.define(version: 20180227165122) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: :cascade do |t|
    t.text    "exchange"
    t.text    "side"
    t.text    "buy_currency"
    t.text    "sell_currency"
    t.decimal "price"
    t.decimal "quantity"
  end

  add_index "orders", ["buy_currency", "sell_currency", "side"], name: "index_orders_on_buy_currency_and_sell_currency_and_side", using: :btree

end
