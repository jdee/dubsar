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

require 'active_support/core_ext/module'

class Fixnum
  def to_s_with_delimiter(*args)
    if args && args.first && args.first.to_sym == :comma_delimited
      # there must be a more standard method, but for now I'm kluging this
      # obviously only works up to 999,999.
      md = /^(\d+)(\d{3})$/.match to_s_without_delimiter
      md ? md[1] + ',' + md[2] : to_s_without_delimiter
    else
      to_s_without_delimiter
    end
  end

  alias_method_chain :to_s, :delimiter
end
