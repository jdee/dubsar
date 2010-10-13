# A set of synonymous words.
class Synset < ActiveRecord::Base
  has_many :words, :dependent => :nullify
end
