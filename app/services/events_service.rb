require "net/http"

class EventsService
  @@MONOLITH_URL = "#{ENV.fetch("MONOLITH_URL")}/api/v1"
  def self.find_by_id(id)
    uri = URI("#{@@MONOLITH_URL}/events/#{id}")
    response = Net::HTTP.get_response(uri)

    parsed_body = JSON.parse(response.body)
    parsed_body["data"]
  end
end



# @@MONOLITH_URL = "#{ENV.fetch("MONOLITH_URL")}/api/v1"
# def self.find_by_id(id)
#   uri = URI("#{@@MONOLITH_URL}/events/#{id}")
#   response = Net::HTTP.get_response(uri)
#   parsed_body = JSON.parse(response.body)
#   parsed_body["data"]
# end

# @@TICKET_URL = "#{ENV.fetch("TICKET_URL")}/api/v1"
# def self.find_by_id(id)
#   uri = URI("#{@@TICKET_URL}/events/#{id}")
#   response = Net::HTTP.get_response(uri)
#   parsed_body = JSON.parse(response.body)
#   parsed_body["data"]
# end
