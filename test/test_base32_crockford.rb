# encoding: utf-8

require 'test/unit'
require 'base32/crockford'

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

