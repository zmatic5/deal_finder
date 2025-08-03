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

ActiveRecord::Schema[8.0].define(version: 2025_08_03_085703) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "deals", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "original_price", precision: 10, scale: 2
    t.decimal "discount_price", precision: 10, scale: 2
    t.integer "discount_percentage"
    t.string "category"
    t.string "subcategory"
    t.string "merchant_name"
    t.float "merchant_rating"
    t.integer "quantity_sold"
    t.date "expiry_date"
    t.boolean "featured_deal"
    t.string "image_url"
    t.text "fine_print"
    t.integer "review_count"
    t.float "average_rating"
    t.integer "available_quantity"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_deals_on_category"
    t.index ["discount_price"], name: "index_deals_on_discount_price"
    t.index ["latitude", "longitude"], name: "index_deals_on_latitude_and_longitude"
  end
end
