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

ActiveRecord::Schema.define(version: 20200408133941) do

  create_table "orders", force: :cascade do |t|
    t.integer "shopify_id", limit: 8
    t.index ["shopify_id"], name: "index_orders_on_shopify_id", unique: true
  end

  create_table "refunds", force: :cascade do |t|
    t.integer "shopify_id", limit: 8
    t.index ["shopify_id"], name: "index_refunds_on_shopify_id", unique: true
  end

end
