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

module Delimiter

  protected

  def delimit_number(delimiter=',')
    md = /^(\d+)(\d{3})$/.match to_s_without_delimiter
    md ? md[1].to_i.delimit_number(delimiter) + delimiter + md[2] : to_s_without_delimiter
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

class Fixnum
  include Delimiter
end
