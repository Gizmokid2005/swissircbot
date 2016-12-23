require 'net/http'
require 'json'

class Wunderground
  include Cinch::Plugin

  match /wu (.+)$/i

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
      uri = URI.parse("http://api.wunderground.com/api/#{WUWEATHERAPIKEY}/conditions/forecast/q/#{@latlong.gsub(" ",",")}.json")
      Net::HTTP.start(uri.host, uri.port) do |http|

        resp        = Net::HTTP.get_response(uri)
        data        = JSON.parse(resp.body)

        if data.include?('current_observation')

          weather     = data['current_observation']
          forecast    = data['forecast']
          location    = weather['display_location']['full']
          time        = weather['observation_time'].partition(", ").last
          wxdesc      = weather['weather']
          temp        = weather['temperature_string']
          feelslike   = weather['feelslike_string']
          humidity    = weather['relative_humidity']
          winddir     = weather['wind_dir']
          windmph     = weather['wind_mph']
          windkph     = weather['wind_kph']
          link        = weather['ob_url']
          fcday1      = forecast['txt_forecast']['forecastday'][0]['title']
          fcday1txt   = forecast['txt_forecast']['forecastday'][0]['fcttext']
          fcday2      = forecast['txt_forecast']['forecastday'][1]['title']
          fcday2txt   = forecast['txt_forecast']['forecastday'][1]['fcttext']
          fcday1f     = forecast['simpleforecast']['forecastday'][0]['high']['fahrenheit']
          fcday1c     = forecast['simpleforecast']['forecastday'][0]['high']['celsius']
          fcday2f     = forecast['simpleforecast']['forecastday'][0]['low']['fahrenheit']
          fcday2c     = forecast['simpleforecast']['forecastday'][0]['low']['celsius']
          fcday1txt = fcday1txt.gsub(fcday1f + "F", fcday1f + "F (" + fcday1c + "C)")
          fcday2txt = fcday2txt.gsub(fcday2f + "F", fcday2f + "F (" + fcday2c + "C)")

          return Format(:bold,"Current:: #{location}") + " (As of #{time}) - " + Format(:bold,"#{wxdesc}::") + " #{temp} | " + Format(:bold,"FL:") + " #{feelslike}, " + Format(:bold,"Humidity:") + " #{humidity}, " + Format(:bold,"Wind:") + " #{winddir} #{windmph}mph (#{windkph}kph) | " + Format(:bold,"#{fcday1}") + ": #{fcday1txt} " + Format(:bold,"#{fcday2}") + ": #{fcday2txt} - #{link}"

        elsif data.include?('response')

          error       = data['response']['error']
          details     = error['description']
          type        = error['type']

          return "Sorry, the API returned error type: '#{type}' with a description of: '#{details}'."

        else

          return "Well...this was unexpected. No weather data for you, sorry."

        end

      end

    else

      return "That doesn't appear to be a valid location."

    end

  end

end