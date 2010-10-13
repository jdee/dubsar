# This class represents a single definition entry for a single word.
class Definition < ActiveRecord::Base
  belongs_to :word

  validates :body, :presence => true
end
