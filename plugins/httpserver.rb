require 'forwardable'
require 'sinatra'
require 'thin'

class Httpserver
  include Cinch::Plugin

  class CinchHttpServer < Sinatra::Base

    def self.bot=(bot)
      @bot = bot
    end

    def self.bot
      @bot
    end

    def bot
      self.class.bot
    end

  end

  # Extend your plugins with this module to allow them
  # to register routes to the HTTP server. You’ll get
  # direct access to Sinatra’s ::get, ::put, ::post,
  # ::patch, and ::delete methods.
  module Verbs
    extend Forwardable
    delegate [:get, :put, :post, :patch, :delete] => CinchHttpServer
  end

  include Cinch::Plugin
  listen_to :connect,    :method => :start_http_server
  listen_to :disconnect, :method => :stop_http_server

  def start_http_server(msg)
    host    = HTTPHOST    || "localhost"
    port    = HTTPPORT    || 1234
    logfile = HTTPLOG     || :cinch

    bot.info "Starting HTTP server on #{host} port #{port}"

    # Set up thin with our Rack endpoint
    @httpserver = Thin::Server.new(host,
                               port,
                               CinchHttpServer,
                               signals: false)

    file = File.open(logfile.to_str, "a")
    file.sync = true
    @httpserver.app.use(Rack::CommonLogger, file)
    @httpserver.app.bot = bot
    @httpserver.start
  end

  def stop_http_server(msg)
    bot.info "Halting HTTP server"
    @httpserver.stop!
  end

end