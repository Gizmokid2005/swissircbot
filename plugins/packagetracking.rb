require 'easypost'
require 'ffaker'
require_relative 'shorten'

class Packagetracking
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
ptrack <trackingnum> <optname>
  This will track your package!
  HELP

  match /ptrack ?((\w+):)?(\w+)? ?(.+)?/i, method: :ptrack
  match /pstatus(?: (.+))?/i, method: :pstatus

  def ptrack(m, xx, tracknum, name)
    #Track the given package, give it a name if it doesn't have one already.

    # Fix the name if it's null
    if name.nil?
      name = FFaker::Product.product
    end

    m.reply name
  end

  def pstatus(m, tracknum)
    #return the status of the given package, or all packages not delivered if not specified

  end

  private

  def setup_api
    EasyPost.api_key = EPAPIKEY #FIXME: Maybe try to find a new place for this?
  end

end