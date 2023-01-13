require 'net/http'
require 'json'
require_relative 'shorten'

class Pirateweather
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
w/wu/wg <location>
  This will return the weather for location from PirateWeather.
wf/fc <location>
  This will return the next 3 days' forecast for location from PirateWeather.
w+f <location>
  This will return the weather and next 3 days' forecast for location from PirateWeather.
  HELP

  match /(?:w|wu|wg)(?=\s|$)(?: (.+))?/i, method: :current
  match /(?:wf|fc)\b(?: (.+))?/i, method: :cforecast
  match /w\+f\b(?: (.+))?/i, method: :cboth

  def current(m, location)
    if !is_blacklisted?(m.channel, m.user.nick)
      if location.nil?
        cfg = db_config_get(m.user.authname.presence || m.user.nick, 'weather', 'location')
        if !cfg[0].nil?
          location = cfg[0][4]
          m.reply curweather(location), true
        else
          m.reply "Sorry, you need to include or set a location.", true
        end
      else
        m.reply curweather(location), true
      end
    else
      m.user.send BLMSG
    end
  end

  def cforecast(m, location)
    if !is_blacklisted?(m.channel, m.user.nick)
      if location.nil?
        cfg = db_config_get(m.user.authname.presence || m.user.nick, 'weather', 'location')
        if !cfg[0].nil?
          location = cfg[0][4]
          m.reply curforecast(location), true
        else
          m.reply "Sorry, you need to include or set a location.", true
        end
      else
        m.reply curforecast(location), true
      end
    else
      m.user.send BLMSG
    end
  end

  def cboth(m, location)
    if !is_blacklisted?(m.channel, m.user.nick)
      if location.nil?
        cfg = db_config_get(m.user.authname.presence || m.user.nick, 'weather', 'location')
        if !cfg[0].nil?
          location = cfg[0][4]
          m.reply curweather(location), true
          m.reply curforecast(location), true
        else
          m.reply "Sorry, you need to include or set a location.", true
        end
      else
        m.reply curweather(location), true
        m.reply curforecast(location), true
      end
    else
      m.user.send BLMSG
    end
  end

  private


  def curweather(location)
    # PirateWeather doesn't provide a coordinate lookup. Grab it from Mapbox first:
    coords, locname = getcoords(location)

    if !coords.nil?
      uri = URI.parse("https://dev.pirateweather.net/forecast/#{PIRATEWEATHERAPIKEY}/#{coords['lat']},#{coords['lng']}?exclude=minutely,hourly,flags")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        begin
          data = JSON.parse(Net::HTTP.get_response(uri).body)
          fc = data['daily']['data']

          if data.include?('currently')
            dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
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
            fchigh      = "#{fc[0]['temperatureHigh'].round(1)}°F (#{((fc[0]['temperatureHigh'] - 32) * (5.0/9)).round(1)}°C)"
            fcsum       = fc[0]['summary']
            alerts      = if data['alerts'].nil?
                            nil
                          elsif data['alerts'].count == 1
                            data['alerts'][0]['title']
                          else
                            data['alerts'].count
                          end
            link        = "https://merrysky.net/forecast/#{coords['lat']},#{coords['lng']}/"

            return Format(:bold,"Currently in #{locname}") + " (As of #{time}) - " + Format(:bold,"#{wxdesc}:") + " #{temp} | " + Format(:bold,"FL:") + " #{feelslike}, " + Format(:bold,"Humidity:") + " #{humidity}, " + Format(:bold,"DewPoint:") + " #{dewpt}, " + Format(:bold,"Wind:") + " #{winddir} #{windmph}mph (#{windkph}kph) " + Format(:bold, "Today: ") + "#{fcsum} " + Format(:bold, "High:") + " of #{fchigh}" + " | #{summary} " + Format(:bold,"#{"| Alerts: #{alerts} " unless alerts.nil? || alerts == 0}") + "-- #{Shorten.shorten(link)}"

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

  def curforecast(location)
    # PirateWeather doesn't provide a coordinate lookup. Grab it from Mapbox first:
    coords, locname = getcoords(location)

    if !coords.nil?
      uri = URI.parse("https://dev.pirateweather.net/forecast/#{PIRATEWEATHERAPIKEY}/#{coords['lat']},#{coords['lng']}?exclude=minutely,hourly,flags")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        begin
          data = JSON.parse(Net::HTTP.get_response(uri).body)
          if data.include?('daily')
            dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
            fc          = data['daily']['data']
            day1        = Time.at(fc[1]['time']).strftime("%A")
            day1sum     = fc[1]['summary']
            day1high    = "#{fc[1]['temperatureHigh'].round(1)}°F (#{((fc[1]['temperatureHigh'] - 32) * (5.0/9)).round(1)}°C)"
            day1low     = "#{fc[1]['temperatureLow'].round(1)}°F (#{((fc[1]['temperatureLow'] - 32) * (5.0/9)).round(1)}°C)"
            day1windmph = fc[1]['windSpeed'].round
            day1windkph = (fc[1]['windSpeed'].round * 1.609344).round
            day1winddir = dirs[((fc[1]['windBearing']/22.5 + 0.5).floor % 16)]
            day2        = Time.at(fc[2]['time']).strftime("%A")
            day2sum     = fc[2]['summary']
            day2high    = "#{fc[2]['temperatureHigh'].round(1)}°F (#{((fc[2]['temperatureHigh'] - 32) * (5.0/9)).round(1)}°C)"
            day2low     = "#{fc[2]['temperatureLow'].round(1)}°F (#{((fc[2]['temperatureLow'] - 32) * (5.0/9)).round(1)}°C)"
            day2windmph = fc[2]['windSpeed'].round
            day2windkph = (fc[2]['windSpeed'].round * 1.609344).round
            day2winddir = dirs[((fc[2]['windBearing']/22.5 + 0.5).floor % 16)]
            day3        = Time.at(fc[3]['time']).strftime("%A")
            day3sum     = fc[3]['summary']
            day3high    = "#{fc[3]['temperatureHigh'].round(1)}°F (#{((fc[3]['temperatureHigh'] - 32) * (5.0/9)).round(1)}°C)"
            day3low     = "#{fc[3]['temperatureLow'].round(1)}°F (#{((fc[3]['temperatureLow'] - 32) * (5.0/9)).round(1)}°C)"
            day3windmph = fc[3]['windSpeed'].round
            day3windkph = (fc[3]['windSpeed'].round * 1.609344).round
            day3winddir = dirs[((fc[3]['windBearing']/22.5 + 0.5).floor % 16)]

            link        = "https://merrysky.net/forecast/#{coords['lat']},#{coords['lng']}/"

            return "Forecast for " + Format(:bold, locname) + ": On " + Format(:bold, "#{day1}: ") + "#{day1sum}: #{day1high} / #{day1low}, " + "Wind: #{day1winddir} #{day1windmph}mph (#{day1windkph}kph); " + Format(:bold, "#{day2}: ") + "#{day2sum}: #{day2high} / #{day2low}, " + "Wind: #{day2winddir} #{day2windmph}mph (#{day2windkph}kph); " + Format(:bold, "#{day3}: ") + "#{day3sum}: #{day3high} / #{day3low}, " + "Wind: #{day3winddir} #{day3windmph}mph (#{day3windkph}kph)" + " -- #{Shorten.shorten(link)}"
          else
            return "I've run into an unexpected error."
          end
        rescue JSON::ParserError
          return "Sorry, the API returned an invalid/missing JSON."
        end
      end
    end
  end

  def getcoords(location)
    uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{CGI::escape(location)}&key=#{GOOGLEAPIKEY}")

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
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