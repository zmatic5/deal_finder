require 'rails_helper'

RSpec.describe DealFinderService, type: :service do
  let!(:deal_center) { create(:deal, title: "Center Deal", latitude: 10.0, longitude: 10.0, discount_percentage: 70, average_rating: 4.0) }
  let!(:deal_nearby) { create(:deal, title: "Nearby High Rating", latitude: 10.01, longitude: 10.01, discount_percentage: 50, average_rating: 5.0) }
  let!(:deal_far) { create(:deal, title: "Far High Discount", latitude: 50.0, longitude: 50.0, discount_percentage: 99, average_rating: 3.0) }
  let!(:deal_other_category) { create(:deal, title: "Other Category", latitude: 10.0, longitude: 10.0, category: 'Other') }

  describe '.call' do
    context 'when searching by location' do
      let(:search_params) { { lat: 10.0, lon: 10.0, radius: 2000 } }

      it 'returns only deals within the specified radius' do
        results = described_class.call(search_params)
        result_titles = results.map { |r| r['title'] }

        expect(results.length).to eq(3)
        expect(result_titles).to include("Center Deal", "Nearby High Rating", "Other Category")
        expect(result_titles).not_to include("Far High Discount")
      end

      it 'ranks a closer deal higher than a farther deal with a better rating' do
        results = described_class.call(search_params)
        expect(results.first['title']).to eq("Center Deal")
      end
    end

    context 'when filtering by category' do
      it 'returns only deals in the specified category' do
        search_params = { category: 'Other' }
        results = described_class.call(search_params)
        expect(results.length).to eq(1)
        expect(results.first['title']).to eq('Other Category')
      end
    end

    context 'when filtering by location and category' do
      it 'returns only deals that match both criteria' do
        search_params = { lat: 10.0, lon: 10.0, radius: 2000, category: 'Other' }
        results = described_class.call(search_params)
        expect(results.length).to eq(1)
        expect(results.first['title']).to eq('Other Category')
      end
    end

    context 'when no filters are applied' do
      it 'returns all deals, ranked by score without distance' do
        results = described_class.call({})
        expect(results.first['title']).to eq("Far High Discount")
      end
    end

    context 'when a deal has nil values for ranking attributes' do
      let!(:deal_with_nils) { create(:deal, title: "Nil Deal", discount_percentage: 100, average_rating: nil, quantity_sold: nil) }
      let!(:lesser_deal) { create(:deal, title: "Lesser Deal", discount_percentage: 90, average_rating: nil, quantity_sold: nil) }

      it 'does not crash and calculates a score correctly' do
        allow(Deal).to receive_message_chain(:by_category, :by_price_range, :to_a).and_return([ deal_with_nils, lesser_deal ])

        results = described_class.call({})
        expect(results.first['title']).to eq("Nil Deal")
      end
    end
  end
end
