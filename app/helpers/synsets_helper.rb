#  Dubsar Dictionary Project
#  Copyright (C) 2010-15 Jimmy Dee
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

module SynsetsHelper
  def target_link(target, lexical_class=nil)
    target_text = case target
    when Sense
      target.word.name
    when Synset
      target.words.map(&:name).join(', ')
    end

    target = "#{synset_path(target.synset)}##{target.word.unique_name}" if target.is_a?(Sense)

    if lexical_class
      link_to target_text, target, :class => "lexical #{lexical_class}"
    else
      link_to target_text, target
    end
  end
end
