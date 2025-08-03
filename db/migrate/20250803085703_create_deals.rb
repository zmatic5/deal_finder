class CreateDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      t.string :title
      t.text :description
      t.decimal :original_price, precision: 10, scale: 2
      t.decimal :discount_price, precision: 10, scale: 2
      t.integer :discount_percentage
      t.string :category
      t.string :subcategory
      t.string :merchant_name
      t.float :merchant_rating
      t.integer :quantity_sold
      t.date :expiry_date
      t.boolean :featured_deal
      t.string :image_url
      t.text :fine_print
      t.integer :review_count
      t.float :average_rating
      t.integer :available_quantity
      t.float :latitude
      t.float :longitude

      t.timestamps
    end

    add_index :deals, [:latitude, :longitude]
    add_index :deals, :category
    add_index :deals, :discount_price
  end
end
