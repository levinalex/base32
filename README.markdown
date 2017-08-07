An implementation of Douglas Crockfords Base32-Encoding in Ruby

see <http://www.crockford.com/wrmg/base32.html>

Installation
============

    $ gem install base32-crockford

Changes
=======
    0.2.0 - added optional checksum
    0.1.0 - rename gem to base32-crockford
    0.0.2 - ruby 1.9 compatibility
    0.0.1 - initial release

Usage
=====

    #!/usr/bin/env ruby

    require 'base32/crockford'

    Base32::Crockford.encode(1234)                            # => "16J"
    Base32::Crockford.encode(100**10, :split=>5, :length=>15) # => "02PQH-TY5NH-H0000"
    Base32::Crockford.decode("2pqh-ty5nh-hoooo")              # => 10**100
    Base32::Crockford.encode(1234, checksum: true)            # => "16JD"
    Base32::Crockford.decode("16JD", checksum: true)          # => 1234
