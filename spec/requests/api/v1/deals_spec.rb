require 'swagger_helper'

RSpec.describe 'api/v1/deals', type: :request do
  path '/api/v1/deals' do
    get('list deals') do
      tags 'Deals'
      produces 'application/json'

      parameter name: :lat, in: :query, type: :number, format: :float, required: false, description: 'Latitude of the user for location-based search.'
      parameter name: :lon, in: :query, type: :number, format: :float, required: false, description: 'Longitude of the user for location-based search.'
      parameter name: :radius, in: :query, type: :integer, required: false, description: 'Search radius in meters. Defaults to 5000.'
      parameter name: :category, in: :query, type: :string, required: false, description: 'Filter deals by a specific category (e.g., "Food & Drink").'
      parameter name: :min_price, in: :query, type: :number, format: :float, required: false, description: 'The minimum discounted price for deals.'
      parameter name: :max_price, in: :query, type: :number, format: :float, required: false, description: 'The maximum discounted price for deals.'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 deals: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       discount_price: { type: :string }, # Represented as string in JSON
                       relevance_score: { type: :number, format: :float }
                     },
                     required: [ 'id', 'title', 'discount_price', 'relevance_score' ]
                   }
                 }
               }

        let!(:deal) { create(:deal, category: 'Food & Drink') }

        let(:category) { 'Food & Drink' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(422, 'invalid request') do
        let(:lat) { '37.7749' }
        run_test!
      end
    end
  end
end
