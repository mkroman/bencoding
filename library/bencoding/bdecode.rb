# encoding: utf-8

# Most of this code is taken from https://github.com/dasch/ruby-bencode/blob/master/lib/bencode/decode.rb
# Thanks for contributing it, dasch!

require 'strscan'

module Bencoding
  class DecodeError < StandardError; end

module_function

  def decode_file path
    decode File.open(path, 'rb').read
  end

  def decode string
    scanner = StringScanner.new string
    parse scanner
  end

  def parse scanner
    case scanner.peek(1)[0]
    when ?i
      scanner.pos += 1
      number = scanner.scan_until(/e/) or raise DecodeError
      number.chop.to_i
    when ?l
      scanner.pos += 1

      Array.new.tap do |result|
        result << parse(scanner) until scanner.scan /e/
      end
    when ?d
      scanner.pos += 1

      Hash.new.tap do |result|
        until scanner.scan(/e/)
          key, value = parse(scanner), parse(scanner)

          raise DecodeError, "invalid key for dictionary" unless key.is_a? String or key.is_a? Fixnum

          result.store "#{key}", value
        end
      end
    when ?0 .. ?9
      length = scanner.scan_until(/:/) or raise DecodeError, "invalid string"

      begin
        length = length.chop.to_i
        string = scanner.peek length
        scanner.pos += length
      rescue RangeError
        raise DecodeError, "invalid string length"
      end

      string
    end
  end
end

class String
  def bdecode; Bencoding.decode self end
end
