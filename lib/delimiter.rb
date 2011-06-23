#  Dubsar Dictionary Project
#  Copyright (C) 2010-11 Jimmy Dee
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'active_support/core_ext'

# The Delimiter module may be included in any class, since it relies
# only on the <tt>#to_s</tt> method. It is automatically included in
# Bignum, Fixnum, Float and String. Any class that mixes in Delimiter
# gains an option to <tt>#to_s</tt>, <tt>:delimiter => string</tt>,
# which will group the digits of the number by thousands using the
# specified +string+ as a delimiter. See
# <tt>spec/lib/delimiter_spec.rb</tt> for detailed examples.
#
#   require 'delimiter'
#   1_234.to_s(:delimiter => ',') # => '1,234'

module Delimiter

  protected

  def delimit_number(delimiter=',')
    # DEBT: The delimiter used for the number should really be tied to
    # the locale, rather than specified as an option. In particular,
    # in European locales that use the period (.) to delimit thousands,
    # usually the decimal point is indicated with a comma (,) instead.
    # Here, when recognizing a fractional decimal, we will accept both
    # the comma and the period as decimal points. This might have some
    # screwy consequences, like:
    #
    # '5652,45'.to_s(:delimiter => ',') # => '5,652,45'

    md = /^([+-]?\d+)(\d{3}([\.,]\d+)?)$/.match to_s_without_delimiter
    md ? md[1].delimit_number(delimiter) + delimiter + md[2] : to_s_without_delimiter
  end

  private

  def to_s_with_delimiter(*args)
    options = args.first if args && args.first && args.first.is_a?(Hash)
    delimiter = options[:delimiter] if options

    if delimiter
      delimit_number delimiter
    else
      to_s_without_delimiter
    end
  end

  def self.included(base)
    base.class_eval { alias_method_chain :to_s, :delimiter }
  end

end

[Bignum, Fixnum, Float, String].each do |base|
  base.class_eval do
    include Delimiter
  end
end
