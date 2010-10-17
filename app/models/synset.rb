# A set of synonymous words.
class Synset < ActiveRecord::Base
  has_and_belongs_to_many :words

  validates :definition, presence: true

  # Return a collection of +Word+ model objects excluding the one
  # passed in as the +word+ argument.
  def words_except(word)
    words.find :all, conditions: [ 'name not ilike ?', word.name ],
      order: 'name'
  end
end
