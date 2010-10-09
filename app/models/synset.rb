class Synset < ActiveRecord::Base
  has_many :words, :dependent => :nullify
end
