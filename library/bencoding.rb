# encoding: utf-8

require 'bencoding/bencode'
require 'bencoding/bdecode'

module Bencoding
  class << Version = [0,1]
    def to_s; join '.' end
  end
end
