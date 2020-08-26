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

  match /(?:w|wu|wf) (.+)$/i, method: :current
  # match /wf (.+)$/i, method: :forecast

  def current(m, location)
    if !is_blacklisted?(m.channel, m.user.nick)
      m.reply curweather(location), true
    else
      m.user.send BLMSG
    end
  end

  private


  def curweather(location)
    # DarkSky doesn't provide a coordinate lookup. Grab it from Mapbox first:
    coords, locname = getcoords(location)

    if !coords.nil?
      uri = URI.parse("https://api.darksky.net/forecast/#{DARKSKYAPIKEY}/#{coords['lat']},#{coords['lng']}?exclude=minutely,hourly,flags")
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
            link        = "https://darksky.net/forecast/#{coords['lat']},#{coords['lng']}/"

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
    uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI::escape(location)}&key=#{GOOGLEAPIKEY}")

    Net::HTTP.start(uri.host, uri.port) do
      begin
        data = JSON.parse(Net::HTTP.get_response(uri).body)
        if !(data['results'].empty? || data['results'].nil?)
          return data['results'][0]['geometry']['location'], "#{data['results'][0]['formatted_address']}"
        else
          return nil
        end
      rescue JSON::ParserError
        return nil
      end
    end
  end

end