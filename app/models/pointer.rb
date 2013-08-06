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

class Pointer < ActiveRecord::Base
  belongs_to :target, :polymorphic => true
  belongs_to :source, :polymorphic => true

  validates :target, :presence => true
  validates :source, :presence => true
  validates :ptype, :presence => true

  class << self
    def create_new(params)
      search_params = {
        :source_id   => params[:source_id  ] || params[:source].id        ,
        :source_type => params[:source_type] || params[:source].class.name,
        :target_id   => params[:target_id  ] || params[:target].id        ,
        :target_type => params[:target_type] || params[:target].class.name,
        :ptype       => params[:ptype      ]
      }
      where(search_params).first || create(params)
    end

    def help_text(ptype)
      help_list[ptype]
    end

    def help_list
      {
        'antonym' => 'words opposite in meaning',
        'hypernym' => 'more generic terms',
        'instance hypernym' => 'classes of which this is an instance',
        'hyponym' => 'more specific terms',
        'instance hyponym' => 'instances of this class',
        'member holonym' => 'wholes of which this is a member',
        'substance holonym' => 'wholes of which this is an ingredient',
        'part holonym' => 'wholes of which this is a part',
        'member meronym' => 'constituent members',
        'substance meronym' => 'constituent substances',
        'part meronym' => 'constituent parts',
        'attribute' => 'general quality',
        'derivationally related form' => 'cognates, etc.',
        'domain of synset (topic)' => 'related topics',
        'member of this domain (topic)' => 'entries under this topic',
        'domain of synset (region)' => 'relevant region',
        'member of this domain (region)' => 'things relevant to this region',
        'domain of synset (usage)' => 'pertinent to usage',
        'member of this domain (usage)' => 'relevant by usage',
        'entailment' => 'consequence',
        'cause' => 'origin or reason',
        'also see' => 'related entries',
        'verb group' => 'related verbs',
        'similar to' => 'near in meaning, but not exact',
        'participle of verb' => 'root verb',
        'derived from/pertains to' => 'adj: pertinent noun; adv: source noun'
      }
    end
  end
end
