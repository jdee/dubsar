# A set of synonymous words.
class Synset < ActiveRecord::Base
  has_and_belongs_to_many :words

  validates :definition, presence: true
end
