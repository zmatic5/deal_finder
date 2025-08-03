require 'rails_helper'

RSpec.describe Api::V1::DealSearchForm, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      it 'is valid' do
        form = described_class.new(lat: 10.0, lon: 10.0, radius: 2000, category: 'Test', min_price: 10, max_price: 100)
        expect(form).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid if only lat is provided' do
        form = described_class.new(lat: 10.0)
        expect(form).not_to be_valid
        expect(form.errors[:base]).to include("lat and lon must be provided together")
      end

      it 'is invalid if lat is out of range' do
        form = described_class.new(lat: 91.0, lon: 10.0)
        expect(form).not_to be_valid
        expect(form.errors[:lat]).to include("must be between -90 and 90")
      end

      it 'is invalid if lon is out of range' do
        form = described_class.new(lat: 10.0, lon: 181.0)
        expect(form).not_to be_valid
        expect(form.errors[:lon]).to include("must be between -180 and 180")
      end

      it 'is invalid if radius is not a positive integer' do
        form = described_class.new(radius: -10)
        expect(form).not_to be_valid
        expect(form.errors[:radius]).to include("must be greater than 0")
      end

      it 'is invalid if min_price is greater than max_price' do
        form = described_class.new(min_price: 100, max_price: 50)
        expect(form).not_to be_valid
        expect(form.errors[:min_price]).to include("cannot be greater than max_price")
      end

      it 'is invalid if min_price is negative' do
        form = described_class.new(min_price: -10)
        expect(form).not_to be_valid
        expect(form.errors[:min_price]).to include("must be greater than or equal to 0")
      end
    end
  end

  describe '#search_params' do
    it 'returns a hash of non-nil attributes with symbol keys' do
      attributes = { lat: 10.0, lon: 10.0, category: 'Test', min_price: nil }
      form = described_class.new(attributes)

      form_params = form.search_params
      expected_params = {
        lat: 10.0,
        lon: 10.0,
        radius: 5000,
        category: 'Test'
      }

      expect(form_params).to eq(expected_params)
    end
  end
end
