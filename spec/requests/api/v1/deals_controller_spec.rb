require 'rails_helper'

RSpec.describe "Api::V1::DealsController", type: :request do
  describe "GET /api/v1/deals" do
    let!(:deal) { create(:deal) }

    context "with valid parameters" do
      let(:valid_params) { { category: deal.category } }

      it "calls the DealFinderService with correct parameters" do
        expected_service_params = { category: deal.category, radius: 5000 }
        expect(DealFinderService).to receive(:call).with(expected_service_params).and_call_original
        get api_v1_deals_path, params: valid_params
      end

      it "returns an OK (200) status" do
        get api_v1_deals_path, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it "returns a JSON object with a 'deals' key" do
        get api_v1_deals_path, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("deals")
        expect(json_response["deals"]).to be_an(Array)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { lat: 10.0 } }

      it "does not call the DealFinderService" do
        expect(DealFinderService).not_to receive(:call)
        get api_v1_deals_path, params: invalid_params
      end

      it "returns an unprocessable_entity (422) status" do
        get api_v1_deals_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns a JSON object with an 'errors' key" do
        get api_v1_deals_path, params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("errors")
        expect(json_response["errors"]["base"]).to include("lat and lon must be provided together")
      end
    end
  end
end
