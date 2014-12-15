require 'net/http'
require 'json'

class Wunderground
  include Cinch::Plugin

  match /wu (.+)$/

  def execute(m, location)
    m.reply weather(location), true
  end

  private

  def weather(location)

    # Wunderground doesn't seem to have a search within the conditions API so we have to get it first...
    uri = URI.parse("http://autocomplete.wunderground.com/aq?query=#{URI.encode(location)}")
    Net::HTTP.start(uri.host, uri.port) do |h|

      resp = Net::HTTP.get_response(uri)
      @loc = JSON.parse(resp.body)
      #@latlong = loc['RESULTS'][0]['ll']

    end

    if !@loc['RESULTS'][0].nil?

      @latlong = @loc['RESULTS'][0]['ll']

      # http://api.wunderground.com/api/APIKEY/features/settings/q/query.format
      uri = URI.parse("http://api.wunderground.com/api/#{WUWEATHERAPIKEY}/conditions/q/#{@latlong.gsub(" ",",")}.json")
      Net::HTTP.start(uri.host, uri.port) do |http|

        resp        = Net::HTTP.get_response(uri)
        data        = JSON.parse(resp.body)

        if data.include?('current_observation')

          weather     = data['current_observation']
          location    = weather['display_location']['full']
          time        = weather['observation_time'].partition(", ").last
          wxdesc      = weather['weather']
          temp        = weather['temperature_string']
          humidity    = weather['relative_humidity']
          winddir     = weather['wind_dir']
          windmph     = weather['wind_mph']
          windkph     = weather['wind_kph']
          visimi      = weather['visibility_mi']
          visikm      = weather['visibility_km']
          pressurein  = weather['pressure_in']
          pressuremb  = weather['pressure_mb']
          link        = weather['ob_url']

          return Format(:bold,"Current Weather") + " in #{location} (As of #{time}) - " + Format(:underline,"#{wxdesc}") + ", #{temp}, " + Format(:bold,"Humidity:") + " #{humidity}, " + Format(:bold,"Wind:") + " #{winddir} #{windmph}mph (#{windkph}kph), " + Format(:bold,"Visbility:") + " #{visimi}mi (#{visikm}km), " + Format(:bold,"Pressure:") +" #{pressurein}inHg (#{pressuremb}mbar). #{link}"

        elsif data.include?('response')

          error       = data['response']['error']
          details     = error['description']
          type        = error['type']

          return "Sorry, the API returned error type: '#{type}' with a desciption of: '#{details}'."

        else

          return "Well...this was unexpected. No weather data for you, sorry."

        end

      end

    else

      return "That doesn't appear to be a valid location."

    end

  end

end