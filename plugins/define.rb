class Define
  include Cinch::Plugin

  listen_to :message, :private

  match /^(def|define) (.+?) (.+)/i, method: :cdef

  def cdef(m,term,meaning)
    #Do things
  end

end