require 'net/http'
require 'json'

class WorldWeather
  include Cinch::Plugin

  match /weather (.+)$/

  def execute(m, location)
    m.reply "#{m.user.nick}: #{weather(location)}"
  end

  private

  def weather(location)
    # api.worldweatheronline.com/free/v1/weather.ashx?q=<location>&format=JSON&extra=<extraopts>&fx=<yes/no>&includelocation=<yes/no>&key=<apikey>
    uri = URI.parse("https://api.worldweatheronline.com/free/v1/weather.ashx?q=#{URI.encode(location)}&format=JSON&extra=localObsTime&fx=no&includelocation=yes&key=#{WEATHERAPIKEY}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|

      resp        = Net::HTTP.get_response(uri)
      data        = JSON.parse(resp.body)
      weather     = data['data']

      if weather.include?('current_condition')
        curcond     = weather['current_condition'][0]
        location    = weather['nearest_area'][0]['areaName'][0]['value']
        time        = curcond['localObsDateTime']
        wxdesc      = curcond['weatherDesc'][0]['value']
        tempf       = curcond['temp_F']
        tempc       = curcond['temp_C']
        humidity    = curcond['humidity']
        winddir     = curcond['winddir16Point']
        windmph     = curcond['windspeedMiles']
        windkph     = curcond['windspeedKmph']
        visibility  = curcond['visibility']
        pressure    = curcond['pressure']
        return "Current Weather in #{location} as of #{time} - #{wxdesc}, #{tempf}F (#{tempc}C), humidity: #{humidity}%, wind: #{winddir} #{windmph}mph (#{windkph}kph), visibility: #{(visibility.to_i * 0.621371).round(2)}mi (#{visibility}km), pressure: #{(pressure.to_i * 0.02953).round(2)}inHg (#{pressure}mbar)."
      else
        error = weather['error'][0]['msg']
        if error.include? "matching weather location"
          return "#{location} is not a valid location."
        else
          return "#{error}"
        end
      end

    end

  end

end