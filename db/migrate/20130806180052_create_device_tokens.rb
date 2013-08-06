#  Dubsar Dictionary Project
#  Copyright (C) 2010-13 Jimmy Dee
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

class CreateDeviceTokens < ActiveRecord::Migration
  def self.up
    create_table :device_tokens do |t|
      t.string :token
      t.boolean :production

      t.timestamps
    end

    # Is it possible for the same DT to be used in dev and production?
    # This index structure supports that, just in case, though it seems unlikely.
    # Can't find a definitive statement though.
    add_index :device_tokens, [:token, :production], :unique => true
  end

  def self.down
    remove_index :device_tokens, :token
    drop_table :device_tokens
  end
end
