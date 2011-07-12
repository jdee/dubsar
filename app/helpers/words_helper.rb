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

module WordsHelper
  def page_title
    "Dubsar - #{search_title}"
  end

  def search_title
    page = ''
    unless @words.blank? or @words.total_pages <= 1
      page = " (p. #{params[:page] || 1})"
    end
    "#{@title || @term}#{page}"
  end

  def frame_spanner(frame)
    frame.gsub('PP', '<span title="prepositional phrase">PP</span>')
  end

  def marker_spanner(marker)
    case marker
    when 'p'
      '<span title="only used in predicate position">(p)</span>'
    when 'a'
      '<span title="only used in prenominal (attributive) position">(a)</span>'
    when 'ip'
      '<span title="only used in immediately postnominal position">(ip)</span>'
    else
      ''
    end
  end

  def model_count(model)
    eval(model.capitalize).count.to_s :delimiter => ','
  end

  def part_of_speech_count(model, part_of_speech)
    case model.to_sym
    when :inflection
      Inflection.count :conditions => [ 'words.part_of_speech = ?', part_of_speech ], :joins => 'INNER JOIN words ON words.id = inflections.word_id'
    when :word
      Word.count :conditions => [ 'part_of_speech = ?', part_of_speech ]
    end
  end

  def meta_description(title, words)
    "Dubsar Dictionary Project search results for #{title}: " +
    words.map do |word|
      entry = word.name + ', ' + word.pos + '.'
      unless word.other_forms.blank?
        entry += " (#{word.other_forms})"
      end
      entry
    end.join('; ')
  end

  def canonical_link_tag
    url = "http://dubsar-dictionary.com#{url_for :action => :search, :term => @term}"
    url += "&match=#{@match}" unless @match.blank?
    url += "&title=#{URI.encode @title}" unless @title.blank?
    url += "&page=#{params[:page]}" unless params[:page].blank? or params[:page].to_i == 1

    s = <<EOF
<link rel="canonical" href="#{url}"/>
EOF
  end

  def mobile_canonical_link_tag
    url = "http://m.dubsar-dictionary.com#{url_for :action => :m_search, :term => @term}"
    url += "&page=#{params[:page]}" unless params[:page].blank? or params[:page].to_i == 1

    s = <<EOF
<link rel="canonical" href="#{url}"/>
EOF
  end

  def target_link(target)
    target_text = case target
    when Sense
      target.word.name
    when Synset
      target.words.map(&:name).join(', ')
    end

    link_to target_text, target, :class => 'search-link'
  end

  def m_target_link(target)
    target_url = case target
    when Sense
      url_for(:controller => :senses, :action => :m_show, :id => target.id, :index => 0)
    when Synset
      url_for(:controller => :synsets, :action => :m_show, :id => target.id)
    end

    target_text = case target
    when Sense
      target.word.name
    when Synset
      target.words.map(&:name).join(', ')
    end

    link_to target_text, target_url
  end

  def search_term
    case @match
    when 'regexp'
      return ''
    end

    defined?(@term) ? @term : ''
  end

  def case_checked?
    defined?(@match) && @match == 'case'
  end

  def mobile_url
    "http://m.dubsar-dictionary.com/m"
  end
end
