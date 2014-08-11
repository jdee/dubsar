class SynsetSuggestion < ActiveRecord::Base
  belongs_to :synset
  scope :autocomplete, ->(term) { where(['suggestion MATCH ?', "#{term}*"]) }
end
