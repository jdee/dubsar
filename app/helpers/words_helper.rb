require 'fixnum'

module WordsHelper
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
end
