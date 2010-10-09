class Definition < ActiveRecord::Base
  belongs_to :word

  validates :body, :presence => true
end
