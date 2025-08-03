module Api
  module V1
    class DealSearchForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :lat, :float
      attribute :lon, :float
      attribute :radius, :integer, default: 5000
      attribute :category, :string
      attribute :min_price, :float
      attribute :max_price, :float

      validates :radius, numericality: { only_integer: true, greater_than: 0 }
      validates :min_price, :max_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
      validate :validate_coordinates_presence
      validate :validate_coordinate_ranges
      validate :validate_price_range

      def search_params
        attributes.compact
      end

      private

      def validate_coordinates_presence
        if lat.present? != lon.present?
          errors.add(:base, "lat and lon must be provided together")
        end
      end

      def validate_coordinate_ranges
        if lat.present? && !lat.between?(-90, 90)
          errors.add(:lat, "must be between -90 and 90")
        end
        if lon.present? && !lon.between?(-180, 180)
          errors.add(:lon, "must be between -180 and 180")
        end
      end

      def validate_price_range
        if min_price.present? && max_price.present? && min_price > max_price
          errors.add(:min_price, "cannot be greater than max_price")
        end
      end
    end
  end
end
