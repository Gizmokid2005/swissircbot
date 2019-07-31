require 'easypost'
require 'ffaker'
require 'json'
require 'csv'
require_relative 'shorten'

class Packagetracking
  include Cinch::Plugin
  include CustomHelpers
  include PackageTrackingHelpers
  extend Httpserver::Verbs

  set :help, <<-HELP
ptrack [optcarrier:]<opttrackingnumber> [optname]
  This will track your package with the [optcarrier] if given, otherwise we'll try to lookup the carrier and track <trackingnumber> with [optname] (or we'll randomly generate one) and watch it until it's delivered. If you don't provide a tracking number we'll give you the status of all packages currently being watched.
pstatus <trackingnumber>
  If given, this will return the status of the given package without watching it.
psearch <carrier>
  This will return the carrier string to use if you need to manually specify which carrier to track with. (Always sends results in PM).
  HELP

  match /ptrack ?((\w+):)?(\w+)? ?(.+)?/i, method: :ptrack
  match /pstatus ?((\w+):)?(\w+)? ?/i, method: :pstatus
  match /psearch(?: (.+))?/i, method: :psearch

  def ptrack(m, xx, courier, tracknum, name)
    #Track the given package

    if tracknum.nil?
      #If we didn't get a tracking number, return the status for all packages we're tracking for the user.
      pkgs = track_all_existing_packages(m.user.nick)
      if pkgs.present?
        pkgs.each do |pkg|
          m.reply pkg, true
        end
      else
        m.reply "I'm not watching any packages for you right now.", true
      end
    else
      #Track only the given package

      #Do we already have this package?
      if db_find_package(m.user.nick, tracknum).present?
        #If we do, remove it from the database to track
        if db_remove_package(m.user.nick, tracknum)
          m.reply "You got it boss, I'll stop watching that for you.", true
        else
          m.reply "I'm already tracking this package but couldn't remove it, sorry.", true
        end
      else
        #Otherwise process this as a new tracking request

        #Generate a name if one wasn't provided
        if name.nil?
          name = FFaker::Product.product
        end

        #Track the package
        pkg = track_new_package(courier, tracknum)
        if pkg.present?
          m.reply string_new_package(name, pkg), true
          #Save the package
          m.reply "Sorry, I couldn't save that package", true unless save_package(m.user.nick, name, pkg) == 1
        else
          m.reply "Sorry, I ran into an unexpected error.", true
        end
      end
    end
  end

  def pstatus(m, xx, courier, tracknum)
    #Return the status of the given package, or all packages not delivered if not specified

    if tracknum.nil?
      #We can't give the status of nothing.
      m.reply "What do you want the status of boss?", true
    else
      pkg = track_new_package(courier, tracknum)
      if pkg.nil?
        m.reply "Sorry, I couldn't find that package", true
      else
        m.reply string_status(pkg), true
      end
    end
  end

  def psearch(m, search)
    # This will return the carrier string to pass to a tracking element if needed - which we'll PM just in case there's multiple messages to not spam the channel.
    if search.nil?
      m.reply "Use this to lookup the carrier string to specify with your tracking information (replies in PM): ie - 'psearch DHL'", true
    elsif search.length < 3
      m.reply "Please enter at least 3 characters to search.", true
    else
      carriers = find_carrier(search)
      if carriers.present?
        carriers.each do |c|
          m.user.msg c, false
        end
      else
        m.reply "Sorry, no carriers found.", true
      end
    end
  end

  # Process Webhooks
  post "/ircbot/webhooks/ptracking" do
    json = JSON.parse(request.body.read)
    push_update(json)
    204
  end

  private
  
  def string_new_package(name, json)
    #Formats the json to a consistently formatted string for new packages
    if json['status'] == 'unknown'
      shorturl  = Shorten.shorten(json['public_url'])
      return "\"#{name}\" is currently unknown, but I'll keep an eye on it for you -- #{shorturl}"
    else
      location  = String.new
      location  << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
      location  << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
      location  << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
      location  << "\"" unless location.empty?
      carrier   = json['carrier']
      status    = json['tracking_details'][-1]['message'].presence || json['status']
      hours     = json['est_delivery_date'].nil? ? 'unknown' : ((Time.parse(json['est_delivery_date']) - Time.now) / 3600).to_i
      shorturl  = Shorten.shorten(json['public_url'])

      return "#{carrier} has \"#{name}\" at \"#{status}\"#{location} which will be delivered in #{hours} hours. I'll let you know when it changes -- #{shorturl}"
    end
  end

  def string_existing_package(name, json)
    #Formats the json to a consistently formatted string for new packages

    location  = String.new
    location  << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
    location  << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
    location  << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
    location  << "\"" unless location.empty?
    carrier   = json['carrier']
    status    = json['tracking_details'][-1]['message'].presence || json['status']
    hours     = ((Time.parse(json['est_delivery_date']) - Time.now) / 3600).to_i
    shorturl  = Shorten.shorten(json['public_url'])

    return "#{carrier} has \"#{name}\" at \"#{status}\"#{location} which will be delivered in #{hours} hours -- #{shorturl}"
  end

  def string_status(json)
    #Formats the json to a consistently formatted string for package statuses

    # This is just temporary for debugging as I finish things up. FIXME
    pp"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
    pp json
    pp "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

    tracknum  = json['tracking_code']
    carrier   = json['carrier']
    shorturl  = Shorten.shorten(json['public_url'])

    if json['status'] == 'unknown'
      return "\"#{tracknum}\" is currently unknown, but I'll keep an eye on it for you -- #{shorturl}"
    else
      status    = json['tracking_details'][-1]['message'].presence || json['status']

      if json['status'] == 'delivered'
        return "#{carrier} has delivered \"#{tracknum}\" at #{Time.parse(json['tracking_details'][-1]['datetime'])} -- #{shorturl}"
      end

      location  = String.new
      location  << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
      location  << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
      location  << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
      location  << "\"" unless location.empty?
      hours     = ((Time.parse(json['est_delivery_date']) - Time.now) / 3600).to_i

      return "\"#{tracknum}\" is currently with #{carrier} at \"#{status}\"#{location} and will be delivered in #{hours} hours -- #{shorturl}"
    end
  end

  def track_new_package(courier, tracknum)
    setup_api

    if courier.nil?
      begin
        #If the courier isn't provided, we need to grab it and provide it to the API to get accurate information.
        tmpjson = JSON.parse(EasyPost::Tracker.create({tracking_code: tracknum}).to_json)
        courier = tmpjson['carrier']
        tmpjson2 = JSON.parse(EasyPost::Tracker.create({tracking_code: tracknum,carrier: courier}).to_json)
        trkid = tmpjson2['id']
        json = JSON.parse(EasyPost::Tracker.retrieve(trkid).to_json)
      rescue EasyPost::Error
        json = nil
      end
    else
      begin
        json = JSON.parse(EasyPost::Tracker.create({tracking_code: tracknum,carrier: courier}).to_json)
      rescue EasyPost::Error
        json = nil
      end
    end

    return json
  end

  def get_package_status(trk_id, nick, courier, tracknum)
    setup_api

    if trk_id.present?
      json = JSON.parse(EasyPost::Tracker.retrieve(trk_id).to_json)
    else
      if courier.nil?
        begin
          #If the courier isn't provided, we need to grab it and provide it to the API to get accurate information.
          tmpjson = JSON.parse(EasyPost::Tracker.create({tracking_code: tracknum}).to_json)
          courier = tmpjson['carrier']
          json = JSON.parse(EasyPost::Tracker.create({tracking_code: tracknum,carrier: courier}).to_json)
          trkid = json['id']
          json = JSON.parse(EasyPost::Tracker.retrieve(trkid).to_json)
        rescue EasyPost::Error
          json = nil
        end
      else
        begin
          json = JSON.parse(EasyPost::Tracker.create({tracking_code: tracknum,carrier: courier}).to_json)
        rescue EasyPost::Error
          json = nil
        end
      end
    end

    tracknum    = json['tracking_code']
    trk_id      = json['id']
    status      = json['tracking_details'][-1]['status']
    location    = String.new
    location    << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
    location    << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
    location    << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
    location    << "\"" unless location.empty?
    updated_at  = Time.parse(json['updated_at'])
    delivered   = json['status'] == 'delivered' ? 1 : 0

    name = db_update_package_status(nick, trk_id, tracknum, status, location, updated_at, delivered)

    return json, name
  end

  def track_all_existing_packages(nick)
    setup_api
    #Track all of the existing packages for this user

    pkgs = db_get_all_packages(nick)
    if pkgs.any?
      @pkg = Array.new
      pkgs.each do |p|

        trk_id = [0]
        tracknum = p[1]
        name = p[2]
        carrier = p[3]
        # nick = p[4]
        # updated_at = p[5]
        # status = p[6]
        # location = p[7]

        pkg = get_package_status(trk_id, nick, carrier, tracknum)
        @pkg << string_existing_package(name, pkg[0])
      end
    end
    return @pkg
  end

  def find_carrier(search)
    carriers = Array.new
    list = CSV.read("easypostcarriers.txt", { :col_sep => "\t", :headers => true })
    list.find_all {|row| row['Carrier'].downcase.include?(search.downcase) }.each do |c|
      vals = c.to_h
      carriers << "#{vals['Carrier']} can be specified with '#{vals['String Representation']}'"
    end

    return carriers
  end

  def save_package(nick, name, json)

    tracknum    = json['tracking_code']
    trk_id      = json['id']
    courier     = json['carrier']
    if json['tracking_details'].present?
      status      = json['tracking_details'][-1]['message'].presence || json['status']
      location    = String.new
      location    << ("@\"" + json['tracking_details'][-1]['tracking_location']['city'].presence || '') unless json['tracking_details'][-1]['tracking_location']['city'].nil?
      location    << (", " + json['tracking_details'][-1]['tracking_location']['state'].presence) unless json['tracking_details'][-1]['tracking_location']['state'].nil?
      location    << (", " + json['tracking_details'][-1]['tracking_location']['country'].presence + "\"") unless json['tracking_details'][-1]['tracking_location']['country'].nil?
      location    << "\"" unless location.empty?
    else
      status      = json['status']
      location    = 'unknown'
    end

    updated_at  = Time.parse(json['updated_at'])
    delivered   = json['status'] == 'delivered' ? 1 : 0

    return db_save_new_package(nick, trk_id, tracknum, courier, name, status, location, updated_at, delivered)
  end

  def setup_api
    EasyPost.api_key = EPAPIKEY #FIXME: Maybe try to find a new place for this?
  end

end