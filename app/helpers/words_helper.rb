require 'fixnum'

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
    eval(model.capitalize).count.to_s :comma_delimited
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
    url = "http://dubsar-dictionary.com?term=#{URI.encode @term}"
    url += "&match=#{@match}" unless @match.blank?
    url += "&title=#{URI.encode @title}" unless @title.blank?

    s = <<EOF
<link rel="canonical" href="#{url}"/>
EOF
  end
end
