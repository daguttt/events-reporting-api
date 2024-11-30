require "net/http"

class EventsService
  MONOLITH_URL = "#{ENV.fetch("MONOLITH_URL")}/es"
  def self.find_by_id(id)
    uri = URI.parse(MONOLITH_URL)
    response = nil
    begin
      Net::HTTP.start(uri.host, use_ssl: uri.scheme == "https", open_timeout: 1, read_timeout: 2) do |http|
        response = http.get("#{uri.path}/events/#{id}.json")
      end
    rescue SocketError
      Rails.logger.error("Could not connect to the monolith")
      return nil
    rescue Net::OpenTimeout, Net::ReadTimeout
      Rails.logger.error("Timeout error: Could not connect to the monolith")
      return nil
    end

    return nil if response.nil? || response.is_a?(Net::HTTPNotFound)

    JSON.parse(response.body)
  end
end
