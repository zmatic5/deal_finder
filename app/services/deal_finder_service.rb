class DealFinderService
  DealWithDistance = Struct.new(:deal, :distance)

  WEIGHTS = { discount: 0.4, rating: 0.3, distance: 0.2, popularity: 0.1 }.freeze
  MAX_DISTANCE_KM = 50.0

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params.with_indifferent_access
  end

  def call
    base_deals = fetch_base_deals
    return [] if base_deals.empty?

    if location_search?
      find_and_rank_by_location(base_deals)
    else
      rank_without_location(base_deals)
    end
  end

  private

  def fetch_base_deals
    Deal.by_category(@params[:category])
        .by_price_range(@params[:min_price], @params[:max_price])
        .to_a
  end

  def location_search?
    @params[:lat].present? && @params[:lon].present?
  end

  def find_and_rank_by_location(deals)
    deals_with_distance = calculate_distances_for(deals)
    nearby_deals = filter_by_radius(deals_with_distance)

    ranked_deals = nearby_deals.map do |item|
      score = calculate_relevance_score(item.deal, item.distance)
      item.deal.attributes.merge(relevance_score: score)
    end

    ranked_deals.sort_by { |d| -d[:relevance_score] }
  end

  def calculate_distances_for(deals)
    search_point = [@params[:lat], @params[:lon]]
    deals.map do |deal|
      deal_point = [deal.latitude, deal.longitude]
      distance = Geocoder::Calculations.distance_between(search_point, deal_point, units: :km)
      DealWithDistance.new(deal, distance)
    end
  end

  def filter_by_radius(deals_with_distance)
    radius_in_km = @params.fetch(:radius, 5000).to_f / 1000.0
    deals_with_distance.select do |item|
      item.distance && item.distance <= radius_in_km
    end
  end

  def calculate_relevance_score(deal, distance_km)
    score = score_for_discount(deal) +
      score_for_rating(deal) +
      score_for_popularity(deal)
    score += score_for_distance(distance_km) if distance_km
    score.round(2)
  end

  def score_for_discount(deal)
    (deal.discount_percentage || 0) * WEIGHTS[:discount]
  end

  def score_for_rating(deal)
    ((deal.average_rating || 0) * 20) * WEIGHTS[:rating]
  end

  def score_for_popularity(deal)
    ([deal.quantity_sold || 0, 1000].min / 10.0) * WEIGHTS[:popularity]
  end

  def score_for_distance(distance_km)
    normalized_distance = [distance_km, MAX_DISTANCE_KM].min / MAX_DISTANCE_KM
    (1 - normalized_distance) * 100 * WEIGHTS[:distance]
  end

  def rank_without_location(deals)
    ranked_deals = deals.map do |deal|
      score = calculate_relevance_score(deal, nil)
      deal.attributes.merge(relevance_score: score)
    end

    ranked_deals.sort_by { |d| -d[:relevance_score] }
  end
end
