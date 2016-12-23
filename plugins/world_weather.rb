require 'net/http'
require 'json'

class WorldWeather
  include Cinch::Plugin

  match /weather (.+)$/i

  def execute(m, location)
    m.reply weather(location), true
  end

  private

  def weather(location)
    # api.worldweatheronline.com/free/v1/weather.ashx?q=<location>&format=JSON&extra=<extraopts>&fx=<yes/no>&includelocation=<yes/no>&key=<apikey>
    uri = URI.parse("https://api.worldweatheronline.com/free/v2/weather.ashx?q=#{URI.encode(location)}&format=JSON&extra=localObsTime&fx=no&includelocation=yes&key=#{WWEATHERAPIKEY}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|

      resp        = Net::HTTP.get_response(uri)
      data        = JSON.parse(resp.body)
      weather     = data['data']

      if weather
        if weather['current_condition'].present?

          curcond     = weather['current_condition'][0]
          location    = weather['nearest_area'][0]['areaName'][0]['value']
          time        = DateTime.parse(curcond['localObsDateTime']).strftime("%X")
          wxdesc      = curcond['weatherDesc'][0]['value']
          tempf       = curcond['temp_F']
          tempc       = curcond['temp_C']
          feelsf      = curcond['FeelsLikeF']
          feelsc      = curcond['FeelsLikeC']
          humidity    = curcond['humidity']
          winddir     = curcond['winddir16Point']
          windmph     = curcond['windspeedMiles']
          windkph     = curcond['windspeedKmph']
          visibility  = curcond['visibility']
          pressure    = curcond['pressure']
          Format(:bold,"Current Weather") + " in #{location} as of #{time} - " + Format(:bold,"#{wxdesc}") + ", #{tempf}F (#{tempc}C) | FL: #{feelsf}F (#{feelsc}C), " + Format(:bold,"humidity:") + " #{humidity}%, " + Format(:bold,"Wind:") + " #{winddir} #{windmph}mph (#{windkph}kph), " + Format(:bold,"Visibility:") + " #{(visibility.to_i * 0.621371).round(2)}mi (#{visibility}km), " + Format(:bold,"Pressure:") + " #{(pressure.to_i * 0.02953).round(2)}inHg (#{pressure}mbar)."
        elsif weather['error'].present?
          error = weather['error'][0]['msg']
          if error.include? "matching weather location"
            return "#{location} is not a valid location."
          else
            return "#{error}"
          end

        else
          return "Sorry, something went horribly wrong."
        end

      elsif data
        data['results']['error']['message']
      else
        return "Sorry, something went horribly wrong."
      end

    end

  end

end