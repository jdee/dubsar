require 'test_helper'

class SynsetTest < ActiveSupport::TestCase
  should have_and_belong_to_many :words
  should validate_presence_of :definition
end
