class Deal < ApplicationRecord
  validates :title, :category, :discount_price, :latitude, :longitude, presence: true

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_price_range, ->(min, max) {
    if min && max
      where(discount_price: min..max)
    elsif min
      where("discount_price >= ?", min)
    elsif max
      where("discount_price <= ?", max)
    end
  }
end
