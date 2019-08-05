include CustomHelpers

module PackageTrackingHelpers

  def push_update(raw)
    #This handles all packages that get a webhook update

    bot.warn "******************* THIS IS A PUSH UPDATE JSON ************************"
    pp raw
    bot.warn "**********************END JSON**************************"

    json = raw['result']
    trk_id = json['id']

    pkgs = db_package_by_id(trk_id)
    if pkgs.any?
      @pkg = Array.new
      pkgs.each do |p|
        updated_at  = Time.parse(json['updated_at'])
        last_upd    = Time.parse(p[5])

        if updated_at != last_upd

          # trk_id = [0]
          # tracknum = p[1]
          name = p[2]
          # carrier = p[3]
          # nick = p[4]
          # updated_at = p[5]
          # status = p[6]
          # location = p[7]

          tracknum    = json['tracking_code']
          trk_id      = json['id']
          status      = json['tracking_details'][-1]['status']
          location    = String.new
          location    << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
          location    << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
          location    << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
          # location    << "\"" unless location.empty?
          delivered   = json['status'] == 'delivered' ? 1 : 0

          nick = db_push_update_package(trk_id, tracknum, status, location, updated_at, delivered)[0][0]
          bot.Channel(PTRACKCHAN).send("#{nick}: #{string_pkg_moved(name, json)}")
        end
      end
    else
      bot.warn("I received an update for #{json['id']} with trackno #{json['tracking_code']} but I'm not currently watching this package.")
    end
  end

  def string_pkg_moved(name, json)
    #Formats the json to a consistently formatted string for package moves.

    carrier   = json['carrier']
    shorturl  = Shorten.shorten(json['public_url'])

    if json['status'] == 'delivered'
      return "#{carrier} has delivered \"#{name}\" -- #{shorturl}"
    else
      location  = String.new
      location  << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
      location  << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
      location  << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
      # location  << "\"" unless location.empty?
      status    = json['tracking_details'][-1]['message'].presence || json['status']
      # hours     = ((Time.parse(json['est_delivery_date']) - Time.now) / 3600).to_i
      days      = json['est_delivery_date'].nil? ? 'unknown' : ((Time.parse(json['est_delivery_date']) - Time.now + 25200) / 3600 / 24).ceil

      if json['tracking_details'][-2].present?
        locationold = String.new
        locationold << ("@\"" + json['tracking_details'][-2]['tracking_location']['city'].presence || '') unless json['tracking_details'][-2]['tracking_location']['city'].nil?
        locationold << (", " + json['tracking_details'][-2]['tracking_location']['state'].presence) unless json['tracking_details'][-2]['tracking_location']['state'].nil?
        locationold << (", " + json['tracking_details'][-2]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-2]['tracking_location']['country'].nil?
        # locationold << "\"" unless location.empty?
        statusold    = json['tracking_details'][-2]['message'].presence || json['status']

        return "#{carrier} moved \"#{name}\" from \"#{statusold}\"#{locationold} to \"#{status}\"#{location} with delivery #{days == 0 ? "today" : "in #{pluralize(days, "day", "days")}"} -- #{shorturl}"
      else
        return "#{carrier} moved \"#{name}\" to \"#{status}\"#{location} with delivery #{days == 0 ? "today" : "in #{pluralize(days, "day", "days")}"} -- #{shorturl}"
      end
    end
  end

end