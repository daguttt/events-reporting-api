require "net/http"

class EventsService
  MONOLITH_URL = "#{ENV.fetch("MONOLITH_URL")}/api/v1"
  def self.find_by_id(id)
    uri = URI.parse(MONOLITH_URL)
    response = nil
    begin
      Net::HTTP.start(uri.host, uri.port, open_timeout: 1, read_timeout: 2) do |http|
        response = http.get("#{uri.path}/events/#{id}")
      end
    rescue SocketError
      Rails.logger.error("Could not connect to the monolith")
      nil
    rescue Net::OpenTimeout, Net::ReadTimeout
      Rails.logger.error("Timeout error: Could not connect to the monolith")
      nil
    end

    return nil if response.nil? || response.is_a?(Net::HTTPNotFound)

    parsed_body = JSON.parse(response.body)
    parsed_body["data"]
  end
end
