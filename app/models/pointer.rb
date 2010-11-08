#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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

class Pointer < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :sense

  validates :target, :presence => true
  validates :sense, :presence => true
  validates :ptype, :presence => true

  class << self
    def create_new(params)
      search_params = {
        :sense_id    => params[:sense_id   ] || params[:sense ].id        ,
        :target_id   => params[:target_id  ] || params[:target].id        ,
        :target_type => params[:target_type] || params[:target].class.name,
        :ptype       => params[:ptype      ]
      }
      create(params) unless first(:conditions => search_params)
    end
  end
end
