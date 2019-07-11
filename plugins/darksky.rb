require 'net/http'
require 'json'
require_relative 'shorten'

class Darksky
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
w <location>
  This will return the weather for location from DarkSky.
  HELP
  # wf <location>
  #     This will return the weather and forecast for location from DarkSky.

  match /w (.+)$/i, method: :current
  # match /wf (.+)$/i, method: :forecast

  def current(m, location)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply curweather(location), true
    else
      m.user.send BLMSG
    end
  end

  # def forecast(m,location)
  #   if !is_blacklisted?(m.channel, m.user.nick)
  #     m.reply weather(location), true
  #   else
  #     m.user.send BLMSG
  #   end
  # end

  private

  # def weather(location)
  #   # DarkSky doesn't provide a coordinate lookup. Grab it from Mapbox first:
  #   coords, locname = getcoords(location)
  #
  #   if !coords.empty?
  #     uri = URI.parse("https://api.darksky.net/forecast/#{DARKSKYAPIKEY}/#{coords[1]},#{coords[0]}?exclude=minutely,hourly,flags")
  #     Net::HTTP.start(uri.host, uri.port) do |http|
  #       resp = Net::HTTP.get_response(uri)
  #       begin
  #         data = JSON.parse(resp.body)
  #
  #         if data.include?('currently')
  #           dirs = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
  #           weather     = data['currently']
  #           forecast    = data['forecast']
  #           time        = Time.at(weather['time']).utc.getlocal(('%+.2d:00' % data['offset'])).strftime("%b %d at %H:%M")
  #           wxdesc      = weather['summary']
  #           temp        = "#{weather['temperature'].round(1)}°F (#{((weather['temperature'] - 32) * (5.0/9)).round(1)}°C)"
  #           feelslike   = "#{weather['apparentTemperature'].round(1)}°F (#{((weather['apparentTemperature'] - 32) * (5.0/9)).round(1)}°C)"
  #           humidity    = "#{(weather['humidity']*100).round}%"
  #           winddir     = dirs[((weather['windBearing']/22.5 + 0.5).floor % 16)]
  #           windmph     = weather['windSpeed'].round
  #           windkph     = (weather['windSpeed'].round * 1.609344).round
  #           link        = "https://darksky.net/forecast/#{coords[1]},#{coords[0]}/"
  #           fcday1      = forecast['txt_forecast']['forecastday'][0]['title']
  #           fcday1txt   = forecast['txt_forecast']['forecastday'][0]['fcttext']
  #           fcday2      = forecast['txt_forecast']['forecastday'][1]['title']
  #           fcday2txt   = forecast['txt_forecast']['forecastday'][1]['fcttext']
  #           fcday1f     = forecast['simpleforecast']['forecastday'][0]['high']['fahrenheit']
  #           fcday1c     = forecast['simpleforecast']['forecastday'][0]['high']['celsius']
  #           fcday2f     = forecast['simpleforecast']['forecastday'][0]['low']['fahrenheit']
  #           fcday2c     = forecast['simpleforecast']['forecastday'][0]['low']['celsius']
  #           fcday1txt = fcday1txt.gsub(fcday1f + "F", fcday1f + "F (" + fcday1c + "C)")
  #           fcday2txt = fcday2txt.gsub(fcday2f + "F", fcday2f + "F (" + fcday2c + "C)")
  #
  #           return Format(:bold,"Current:: #{locname}") + " (As of #{time}) - " + Format(:bold,"#{wxdesc}::") + " #{temp} | " + Format(:bold,"FL:") + " #{feelslike}, " + Format(:bold,"Humidity:") + " #{humidity}, " + Format(:bold,"Wind:") + " #{winddir} #{windmph}mph (#{windkph}kph) | " + Format(:bold,"#{fcday1}") + ": #{fcday1txt} " + Format(:bold,"#{fcday2}") + ": #{fcday2txt} - #{link}"
  #
  #         else
  #           return "Well...this was unexpected. No weather data for you, sorry."
  #         end
  #       rescue JSON::ParserError
  #         return "Sorry, the API returned an invalid/missing JSON."
  #       end
  #     end
  #   else
  #     return "That doesn't appear to be a valid location."
  #   end
  # end

  def curweather(location)
    # DarkSky doesn't provide a coordinate lookup. Grab it from Mapbox first:
    coords, locname = getcoords(location)

    if !coords.nil?
      uri = URI.parse("https://api.darksky.net/forecast/#{DARKSKYAPIKEY}/#{coords[1]},#{coords[0]}?exclude=minutely,hourly,flags")
      Net::HTTP.start(uri.host, uri.port) do
        begin
          data = JSON.parse(Net::HTTP.get_response(uri).body)

          if data.include?('currently')
            dirs = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
            weather     = data['currently']
            time        = Time.at(weather['time']).utc.getlocal(('%+.2d:00' % data['offset'])).strftime("%b %d at %H:%M")
            wxdesc      = weather['summary']
            temp        = "#{weather['temperature'].round(1)}°F (#{((weather['temperature'] - 32) * (5.0/9)).round(1)}°C)"
            feelslike   = "#{weather['apparentTemperature'].round(1)}°F (#{((weather['apparentTemperature'] - 32) * (5.0/9)).round(1)}°C)"
            humidity    = "#{(weather['humidity']*100).round}%"
            dewpt       = "#{weather['dewPoint'].round(1)}°F (#{((weather['dewPoint'] - 32) * (5.0/9)).round(1)}°C)"
            winddir     = dirs[((weather['windBearing']/22.5 + 0.5).floor % 16)]
            windmph     = weather['windSpeed'].round
            windkph     = (weather['windSpeed'].round * 1.609344).round
            summary     = data['daily']['summary']
            alerts      = if data['alerts'].nil?
                            nil
                          elsif data['alerts'].count == 1
                            data['alerts'][0]['title']
                          else
                            data['alerts'].count
                          end
            link        = "https://darksky.net/forecast/#{coords[1]},#{coords[0]}/"

            return Format(:bold,"Currently in #{locname}") + " (As of #{time}) - " + Format(:bold,"#{wxdesc}::") + " #{temp} | " + Format(:bold,"FL:") + " #{feelslike}, " + Format(:bold,"Humidity:") + " #{humidity}, " + Format(:bold,"DewPoint:") + " #{dewpt}, " + Format(:bold,"Wind:") + " #{winddir} #{windmph}mph (#{windkph}kph) | #{summary} " + Format(:bold,"#{"| Alerts: #{alerts} " unless alerts.nil?}") + "-- #{Shorten.shorten(link)}"

          else
            return "I've run into an unexpected error."
          end
        rescue JSON::ParserError
          return "Sorry, the API returned an invalid/missing JSON."
        end
      end
    else
      return "That doesn't appear to be a valid location."
    end
  end

  def getcoords(location)
    uri = URI.parse("https://api.mapbox.com/geocoding/v5/mapbox.places/#{CGI::escape(location)}.json?fuzzymatch=true?limit=1?routing=false&access_token=#{MAPBOXAPIKEY}")
    Net::HTTP.start(uri.host, uri.port) do
      begin
        data = JSON.parse(Net::HTTP.get_response(uri).body)
        if !(data['features'].empty? || data['features'].nil?)
          city = if data['features'][0]['id'].include?('place') || data['features'][0]['id'].include?('district')
                   "#{data['features'][0]['text']},"
                 elsif data['features'][0]['context'].select { |p| p['id'].include?('place') }
                   "#{data['features'][0]['context'].select { |p| p['id'].include?('place') }[0]['text']},"
                 end
          state = data['features'][0]['context'].select { |p| p['id'].include?('region')}[0]['text'] unless (data['features'].empty? || data['features'].nil?)
          return data['features'][0]['center'], "#{city} #{state}"
        else
          return nil
        end
      rescue JSON::ParserError
        return nil
      end
    end
  end

end