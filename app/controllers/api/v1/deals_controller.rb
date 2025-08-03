module Api
  module V1
    class DealsController < ApplicationController
      def search
        form = Api::V1::DealSearchForm.new(form_params)

        unless form.valid?
          return render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
        end

        ranked_deals = DealFinderService.call(form.search_params)

        render json: { deals: ranked_deals }, status: :ok
      end

      private

      def form_params
        params.permit(:lat, :lon, :radius, :category, :min_price, :max_price)
      end
    end
  end
end
