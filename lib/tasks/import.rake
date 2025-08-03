namespace :data do
  desc "Import deals"
  task import_deals: :environment do
    file_path = Rails.root.join("data", "data.json")
    abort("Data file not found at #{file_path}") unless File.exist?(file_path)

    deals_data = JSON.parse(File.read(file_path), symbolize_names: true)
    deals_imported = 0

    allowed_attributes = Deal.column_names.map(&:to_sym)

    Deal.transaction do
      deals_data.each do |deal_attrs|
        snake_case_attrs = deal_attrs.deep_transform_keys { |key| key.to_s.underscore.to_sym }

        location_data = snake_case_attrs.delete(:location)
        snake_case_attrs[:latitude] = location_data[:lat]
        snake_case_attrs[:longitude] = location_data[:lng]

        final_attrs = snake_case_attrs.slice(*allowed_attributes)

        Deal.create!(final_attrs)
        deals_imported += 1
      end
    end

    puts "Imported #{deals_imported} deals"
  rescue StandardError => e
    puts "An error occurred during import: #{e.message}"
  end
end
