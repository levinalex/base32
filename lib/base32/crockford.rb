#!/usr/bin/env ruby
# encoding: UTF-8
#
# (c) 2008, Levin Alexander <http://levinalex.net>
#
# This file is released under the same license as ruby.
#

require 'enumerator'

module Base32
end

# encode a value with the encoding defined by _Douglas_ _Crockford_ in
# <http://www.crockford.com/wrmg/base32.html>
#
# this is *not* the same as the Base32 encoding defined in RFC 4648
#
#
# The Base32 symbol set is a superset of the Base16 symbol set.
#
# We chose a symbol set of 10 digits and 22 letters. We exclude 4 of the 26
# letters: I L O U.
#
# Excluded Letters
#
# I:: Can be confused with 1
# L:: Can be confused with 1
# O:: Can be confused with 0
# U:: Accidental obscenity
#
# When decoding, upper and lower case letters are accepted, and i and l will
# be treated as 1 and o will be treated as 0. When encoding, only upper case
# letters are used.
#
# If the bit-length of the number to be encoded is not a multiple of 5 bits,
# then zero-extend the number to make its bit-length a multiple of 5.
#
# Hyphens (-) can be inserted into symbol strings. This can partition a
# string into manageable pieces, improving readability by helping to prevent
# confusion. Hyphens are ignored during decoding. An application may look for
# hyphens to assure symbol string correctness.
#
#
class Base32::Crockford
  ENCODE_CHARS =
    %w(0 1 2 3 4 5 6 7 8 9 A B C D E F G H J K M N P Q R S T V W X Y Z ?)

  DECODE_MAP = ENCODE_CHARS.to_enum(:each_with_index).inject({}) do |h,(c,i)|
    h[c] = i; h
  end.merge({'I' => 1, 'L' => 1, 'O' => 0})

  # encodes an integer into a string
  #
  # when +split+ is given a hyphen is inserted every <n> characters to improve
  # readability
  #
  # when +length+ is given, the resulting string is zero-padded to be exactly
  # this number of characters long (hyphens are ignored)
  #
  #   Base32::Crockford.encode(1234) # => "16J"
  #   Base32::Crockford.encode(123456789012345, :split=>5) # => "3G923-0VQVS"
  #
  def self.encode(number, opts = {})
    # verify options
    raise ArgumentError unless (opts.keys - [:length, :split] == [])

    str = number.to_s(2).reverse.scan(/.{1,5}/).map do |bits|
      ENCODE_CHARS[bits.reverse.to_i(2)]
    end.reverse.join

    str = str.rjust(opts[:length], '0') if opts[:length]

    if opts[:split]
      str = str.reverse
      str = str.scan(/.{1,#{opts[:split]}}/).map { |x| x.reverse }
      str = str.reverse.join("-")
    end

    str
  end

  # decode a string to an integer using Douglas Crockfords Base32 Encoding
  #
  # the string is converted to uppercase and hyphens are stripped before
  # decoding
  #
  #   I,i,l,L decodes to 1
  #   O,o decodes to 0
  #
  #   Base32::Crockford.decode("16J") # => 1234
  #   Base32::Crockford.decode("OI") # => 1
  #   Base32::Crockford.decode("3G923-0VQVS") # => 123456789012345
  #
  # returns +nil+ if the string contains invalid characters and can't be
  # decoded
  #
  def self.decode(string)
    clean(string).split(//).map { |char|
      DECODE_MAP[char] or return nil
    }.inject(0) { |result,val| (result << 5) + val }
  end

  # same as decode, but raises ArgumentError when the string can't be decoded
  #
  def self.decode!(string)
    decode(string) or raise ArgumentError
  end

  # return the canonical encoding of a string. converts it to uppercase
  # and removes hyphens
  #
  # replaces invalid characters with a question mark ('?')
  #
  def self.normalize(string)
    clean(string).split(//).map { |char|
      ENCODE_CHARS[DECODE_MAP[char] || 32]
    }.join
  end

  # returns false iff the string contains invalid characters and can't be
  # decoded
  #
  def self.valid?(string)
    !(normalize(string) =~ /\?/)
  end

  class << self
    def clean(string)
      string.gsub(/-/,'').upcase
    end
    private :clean
  end
end



if __FILE__ == $0

  require 'test/unit'

  class TestBase32Crockford < Test::Unit::TestCase

    def test_encoding_and_decoding_single_chars
      from = (0..31).to_a
      to = %w(0 1 2 3 4 5 6 7 8 9 A B C D E F G H J K M N P Q R S T V W X Y Z)

      from.zip(to) do |symbol_value, encode_symbol|
        assert_equal encode_symbol, Base32::Crockford.encode(symbol_value)
        assert_equal symbol_value, Base32::Crockford.decode(encode_symbol)
      end
    end

    def test_encoding_larger_numbers
      assert_equal("10", Base32::Crockford.encode(32))
      assert_equal("16J", Base32::Crockford.encode(1234))
    end

    def test_decoding_strings
      assert_equal(1234, Base32::Crockford.decode("16J"))
    end

    def test_decoding_normalizes_symbols
      assert_equal Base32::Crockford.decode('11100110'),
                   Base32::Crockford.decode('IL1O0ilo')
    end

    def test_decoding_lowercase
      assert_equal Base32::Crockford.decode("abcdefghijklmnopqrstvwxyz"),
                   Base32::Crockford.decode("ABCDEFGHIJKLMNOPQRSTVWXYZ")
    end

    def test_decoding_invalid_strings
      assert_equal nil, Base32::Crockford.decode("Ü'+?")
      assert_raises(ArgumentError) { Base32::Crockford.decode!("'+?") }
    end

    def test_decode_should_ignore_hyphens
      assert_equal 1234, Base32::Crockford.decode("1-6-j")
    end

    def test_normalize
      assert_equal "HE110W0R1D", Base32::Crockford.normalize("hello-world")
      assert_equal "B?123", Base32::Crockford.normalize("BU-123")
    end

    def test_valid
      assert_equal true, Base32::Crockford.valid?("hello-world")
      assert_equal false, Base32::Crockford.valid?("BU-123")
    end

    def test_length_and_hyphenization
      assert_equal "0016J", Base32::Crockford.encode(1234, :length => 5)
      assert_equal "0-01-6J",
        Base32::Crockford.encode(1234, :length => 5, :split => 2)
      assert_equal "00-010",
        Base32::Crockford.encode(32, :length => 5, :split => 3)
    end
  end
end
